#ifndef _SIBYLENGINE_COMMON_COMPLEX_SLANG_
#define _SIBYLENGINE_COMMON_COMPLEX_SLANG_

/** floating-point complex structure based on pbrt-v4. */
struct complex {
    float re;
    float im;

    __init(float re) { this.re = re; this.im = 0; }
    __init(float re, float im) { this.re = re; this.im = im; }
};
[Differentiable] complex operator +(complex a, complex b) { return complex(a.re + b.re, a.im + b.im); }
[Differentiable] complex operator +(float value, complex z) { return complex(value) + z; }
[Differentiable] complex operator -(complex a, complex b) { return complex(a.re - b.re, a.im - b.im); }
[Differentiable] complex operator -(float value, complex z) { return complex(value) - z; }
[Differentiable] complex operator *(complex a, complex b) {
    return complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re); }
[Differentiable] complex operator *(float value, complex z) { return complex(value) * z; }
[Differentiable] complex operator *(complex z, float value) { return complex(value) * z; }
[Differentiable] complex operator /(complex a, complex b) {
    float scale = 1 / (b.re * b.re + b.im * b.im);
    return complex(scale * (a.re * b.re + a.im * b.im),
                   scale * (a.im * b.re - a.re * b.im)); }
[Differentiable] complex operator /(float value, complex z) { return complex(value) / z; }
[Differentiable] float real(complex z) { return z.re; }
[Differentiable] float imag(complex z) { return z.im; }
[Differentiable] float norm(complex z) { return z.re * z.re + z.im * z.im; }
[Differentiable] float abs(complex z) { return sqrt(norm(z)); }
[Differentiable] complex sqr(complex x) { return x * x; }
[Differentiable] complex sqrt(complex z) {
    const float n = abs(z);
    const float t1 = sqrt(.5 * (n + abs(z.re)));
    const float t2 = .5 * z.im / t1;

    if (n == 0) return complex(0);
    if (z.re >= 0) return { t1, t2 };
    else return complex(abs(t2), copysign(t1, z.im));
}

// complex3 is a structure that holds three complex numbers, useful for representing
struct complex3 {
    complex x, y, z;
    __init(float r) { x = complex(r); y = complex(r); z = complex(r); }
    __init(complex x, complex y, complex z) { this.x = x; this.y = y; this.z = z; }
    __init(float3 r, float3 i) { x = complex(r.x, i.x); y = complex(r.y, i.y); z = complex(r.z, i.z); }
}

[Differentiable] complex3 operator +(complex3 a, complex3 b) { return complex3(a.x + b.x, a.y + b.y, a.z + b.z); }
[Differentiable] complex3 operator +(float value, complex3 z) { return complex3(value + z.x, value + z.y, value + z.z); }
[Differentiable] complex3 operator -(complex3 a, complex3 b) { return complex3(a.x - b.x, a.y - b.y, a.z - b.z); }
[Differentiable] complex3 operator -(float value, complex3 z) { return complex3(value - z.x, value - z.y, value - z.z); }
[Differentiable] complex3 operator *(complex3 a, complex3 b) { return complex3(a.x * b.x, a.y * b.y, a.z * b.z); }
[Differentiable] complex3 operator *(complex3 z, float value) { return complex3(z.x * value, z.y * value, z.z * value); }
[Differentiable] complex3 operator /(complex3 a, complex3 b) { return complex3(a.x / b.x, a.y / b.y, a.z / b.z); }
[Differentiable] complex3 operator /(float value, complex3 z) { return complex3(value / z.x, value / z.y, value / z.z); }
[Differentiable] complex3 sqr(complex3 c) { return complex3(sqr(c.x), sqr(c.y), sqr(c.z)); }
[Differentiable] complex3 sqrt(complex3 c) { return complex3(sqrt(c.x), sqrt(c.y), sqrt(c.z)); }
[Differentiable] float3 norm(complex3 c) { return float3(norm(c.x), norm(c.y), norm(c.z)); }

#endif // _SIBYLENGINE_COMMON_COMPLEX_SLANG_