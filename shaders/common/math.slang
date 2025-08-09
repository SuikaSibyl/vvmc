#ifndef _SIBYLENGINE_MATH_HLSLI_
#define _SIBYLENGINE_MATH_HLSLI_

static const float M_PI = 3.1415926535897932f;
static const float M_2PI = 6.2831853071795864f;
static const float M_PI_OVER_2 = M_PI / 2;
static const float M_PI_OVER_4 = M_PI / 4;
static const float M_INV_PI = 1. / M_PI;
static const float M_INV_2PI = 1. / (2 * M_PI);
static const float M_INV_4PI = 0.07957747154594766788;
static const float M_SQRT2 = 1.41421356237309504880f;
static const float M_INF = 1.0 / 0.0; // Infinity
static const float M_ONE_MINUS_EPSILON = 0.999999940395355225f;
static const float M_MACHINE_EPSILON = 1.0e-6f;
static const float M_FLOAT_MIN = 1.0f / exp2(126);
static const float M_FLOAT_MAX = 3.402823466e+38;
static const int   M_INT_MAX = 2147483647;

float gamma(int n) { return (n * M_MACHINE_EPSILON) / (1 - n * M_MACHINE_EPSILON); }

/** Returns the smallest component of the vector. */
float min_component(in const float3 v) { return min(v.x, min(v.y, v.z)); }
/** Returns the largest component of the vector. */
float max_component(in const float3 v) { return max(v.x, max(v.y, v.z)); }
/** Returns the largest component of the vector. */
float max_component(in const float4 v) { return max(max(v.x, v.y), max(v.z, v.w)); }

float2 interpolate(float2 vertices[3], float3 bary) { return vertices[0] * bary[0] + vertices[1] * bary[1] + vertices[2] * bary[2]; }
float3 interpolate(float3 vertices[3], float3 bary) { return vertices[0] * bary[0] + vertices[1] * bary[1] + vertices[2] * bary[2]; }
float4 interpolate(float4 vertices[3], float3 bary) { return vertices[0] * bary[0] + vertices[1] * bary[1] + vertices[2] * bary[2]; }

[Differentiable] float sqr(float v) { return v * v; }
[Differentiable] float2 sqr(float2 v) { return float2(sqr(v.x), sqr(v.y)); }
[Differentiable] float3 sqr(float3 v) { return float3(sqr(v.x), sqr(v.y), sqr(v.z)); }
[Differentiable] float4 sqr(float4 v) { return float4(sqr(v.x), sqr(v.y), sqr(v.z), sqr(v.w)); }
[Differentiable] float safe_sqrt(float v) { return sqrt(max(v, 0.f)); }
[Differentiable] float2 safe_sqrt(float2 v) { return float2(safe_sqrt(v.x), safe_sqrt(v.y)); }
[Differentiable] float3 safe_sqrt(float3 v) { return float3(safe_sqrt(v.x), safe_sqrt(v.y), safe_sqrt(v.z)); }
[Differentiable] float4 safe_sqrt(float4 v) { return float4(safe_sqrt(v.x), safe_sqrt(v.y), safe_sqrt(v.z), safe_sqrt(v.w)); }
[Differentiable] float distance_squared(in float3 v0, in float3 v1) { return dot(v0 - v1, v0 - v1); }
[Differentiable] float length_squared(in float2 v) { return dot(v, v); }
[Differentiable] float length_squared(in float3 v) { return dot(v, v); }
[Differentiable] float elevation(float3 d) { return 2.f * asin(.5f * sqrt(sqr(d.x) + sqr(d.y) + sqr(d.z - 1.f))); }

[Differentiable] float safe_acos(float x) { return acos(clamp(x, -1, 1)); }
[Differentiable] float safe_asin(float x) { return asin(clamp(x, -1, 1)); }

// Returns the average of the components of a vector.
[Differentiable] float average(float2 v) { return (v.x + v.y) * 0.5f; }
[Differentiable] float average(float3 v) { return (v.x + v.y + v.z) / 3.f; }
[Differentiable] float average(float4 v) { return (v.x + v.y + v.z + v.w) / 4.f; }

// Returns the sum of the components of a vector.
[Differentiable] float sum(float2 v) { return v.x + v.y; }
[Differentiable] float sum(float3 v) { return v.x + v.y + v.z; }
[Differentiable] float sum(float4 v) { return v.x + v.y + v.z + v.w; }

// Swaps two values of the same type.
[Differentiable] void swap(inout float  a, inout float  b) { float temp = a; a = b; b = temp; }
[Differentiable] void swap(inout float2 a, inout float2 b) { float2 temp = a; a = b; b = temp; }
[Differentiable] void swap(inout float3 a, inout float3 b) { float3 temp = a; a = b; b = temp; }
[Differentiable] void swap(inout float4 a, inout float4 b) { float4 temp = a; a = b; b = temp; }

[Differentiable] float hypot(float2 v) { return length(v); }
[Differentiable] float hypot(float3 v) { return length(v); }
[Differentiable] float hypot(float4 v) { return length(v); }
[Differentiable] float hypot(float x, float y) { return length(float2(x, y)); }
[Differentiable] float hypot(float x, float y, float z) { return length(float3(x, y, z)); }
[Differentiable] float hypot(float x, float y, float z, float w) { return length(float4(x, y, z, w)); }

[Differentiable] float luminance(in const float3 rgb) { return dot(rgb, float3(0.212671, 0.715160, 0.072169)); }
[Differentiable] float3 yuv2rgb(float3 yuv) {
    float3 rgb;
    rgb.x = yuv.x + 1.13983f * yuv.z;
    rgb.y = yuv.x - 0.39465f * yuv.y - 0.58060f * yuv.z;
    rgb.z = yuv.x + 2.03211f * yuv.y;
    return rgb;
}

[Differentiable] float angle_between(float3 v1, float3 v2) {
    if (dot(v1, v2) < 0) return M_PI - 2 * safe_asin(length(v1 + v2) / 2);
    else return 2 * safe_asin(length(v2 - v1) / 2);
}

uint hprod<let Dim : int>(vector<uint, Dim> v) {
    uint result = v[0];
    for (int i = 1; i < Dim; ++i)
        result = result * v[i];
    return result;
}

float hprod<let Dim : int>(vector<float, Dim> v) {
    float result = v[0];
    for (int i = 1; i < Dim; ++i)
        result = result * v[i];
    return result;
}

float unpack_cpu_half(uint16_t hdata) {
    int s = (hdata >> 15) & 0x00000001;
    int e = (hdata >> 10) & 0x0000001f;
    int m = hdata & 0x000003ff;

    if (e == 0) {
        if (m == 0) {
            uint32_t result = (uint32_t)(s << 31);
            return asfloat(result);
        }
        else {
            while (!bool(m & 0x00000400)) {
                m <<= 1;
                e -= 1;
            }

            e += 1;
            m &= ~0x00000400;
        }
    }
    else if (e == 31) {
        if (m == 0) {
            uint32_t result = (uint32_t)((s << 31) | 0x7f800000);
            return asfloat(result);
        } else {
            uint32_t result = (uint32_t)((s << 31) | 0x7f800000 | (m << 13));
            return asfloat(result);
        }
    }

    e = e + (127 - 15);
    m = m << 13;

    uint32_t result = (uint32_t)((s << 31) | (e << 23) | m);
    return asfloat(result);
}

float next_float_up(float v) {
    // Handle infinity and negative zero for next_float_up()
    if (isinf(v) && v > 0.f) return v;
    if (v == -0.f) v = 0.f;
    // Advance v to next higher float
    uint32_t ui = asuint(v);
    if (v >= 0) ++ui;
    else --ui;
    return asfloat(ui);
}

float next_float_down(float v) {
    // Handle infinity and positive zero for _NextFloatDown()_
    if (isinf(v) && v < 0.) return v;
    if (v == 0.f) v = -0.f;
    uint32_t ui = asuint(v);
    if (v > 0) --ui;
    else ++ui;
    return asfloat(ui);
}

[Differentiable] float evaluate_polynomial_0(float t, float c) { return c; }
[Differentiable] float ffma(float a, float b, float c) { return a * b + c; }

float evaluate_polynomial_1(float t, float c1, float c0) { return ffma(t, evaluate_polynomial_0(t, c0), c1); }
float evaluate_polynomial_2(float t, float c2, float c1, float c0) { return ffma(t, evaluate_polynomial_1(t, c1, c0), c2); }
float evaluate_polynomial_3(float t, float c3, float c2, float c1, float c0) { return ffma(t, evaluate_polynomial_2(t, c2, c1, c0), c3);}
float evaluate_polynomial_4(float t, float c4, float c3, float c2, float c1, float c0) { return ffma(t, evaluate_polynomial_3(t, c3, c2, c1, c0), c4); }
float evaluate_polynomial_5( float t, float c5, float c4, float c3, float c2, float c1, float c0) { return ffma(t, evaluate_polynomial_4(t, c4, c3, c2, c1, c0), c5); }
float evaluate_polynomial_6(float t, float c6, float c5, float c4, float c3, float c2, float c1, float c0) { return ffma(t, evaluate_polynomial_5(t, c5, c4, c3, c2, c1, c0), c6); }

// decompose a floating-point number into its components
int exponent(float v) { return (asuint(v) >> 23) - 127; }
int significand(float v) { return asuint(v) & ((1 << 23) - 1); }
uint32_t sign_bit(float v) { return asuint(v) & 0x80000000; }
float sample_exponential(float u, float a) { return -log(1 - u) / a; }

float fast_exp(float x) {
    // Compute x' such that e^x = 2^(x')
    float xp = x * 1.442695041f;
    // Find integer and fractional components of x'
    float fxp = floor(xp);
    float f = xp - fxp;
    int i = (int)fxp;
    // <Evaluate polynomial approximation of 2^f
    float twoToF = evaluate_polynomial_3(
        f, 1.f, 0.695556856f,
        0.226173572f, 0.0781455737f);
    // Scale 2^f by 2^i and return final result
    int exponent = exponent(twoToF) + i;
    if (exponent < -126) return 0;
    if (exponent > 127) return M_INF;
    uint32_t bits = asuint(twoToF);
    bits &= 0b10000000011111111111111111111111u;
    bits |= (exponent + 127) << 23;
    return asfloat(bits);
}
float2 fast_exp(float2 v) { return float2(exp(v.x), exp(v.y)); }
float3 fast_exp(float3 v) { return float3(exp(v.x), exp(v.y), exp(v.z)); }

[Differentiable]
float discard_nan_inf(float v) { return (isinf(v) || isnan(v)) ? 0 : v; }
float2 discard_nan_inf(float2 v) { return select(isinf(v) || isnan(v), 0, v); }
float3 discard_nan_inf(float3 v) { return select(isinf(v) || isnan(v), 0, v); }
float4 discard_nan_inf(float4 v) { return select(isinf(v) || isnan(v), 0, v); }

bool is_nan_or_inf(float v) { return isinf(v) || isnan(v); }
bool2 is_nan_or_inf(float2 v) { return isinf(v) || isnan(v); }
bool3 is_nan_or_inf(float3 v) { return isinf(v) || isnan(v); }
bool4 is_nan_or_inf(float4 v) { return isinf(v) || isnan(v); }

#endif // _SIBYLENGINE_MATH_HLSLI_