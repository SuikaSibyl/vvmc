#ifndef _SIBYLENGINE_RANDOM_HLSLI_
#define _SIBYLENGINE_RANDOM_HLSLI_

#define RANDOM_SAMPLER_IMPL_PCG32I 0
#define RANDOM_SAMPLER_IMPL_MURMUR3 1

// By default we use pcg32_i implementation
#ifndef RANDOM_SAMPLER_IMPL
#define RANDOM_SAMPLER_IMPL RANDOM_SAMPLER_IMPL_PCG32I
#endif

namespace random {
/**
 * CRNG
 * @url: https://www.reedbeta.com/blog/hash-functions-for-gpu-rendering/
 */
uint hash_crng(uint seed) {
    const uint state = seed * 747796405u + 2891336453u;
    const uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}

/**
* Jenkins
// @url: http://burtleburtle.net/bob/hash/integer.html
*/
uint hash_jenkins(uint a) {
    a = (a + 0x7ed55d16) + (a << 12);
    a = (a ^ 0xc761c23c) ^ (a >> 19);
    a = (a + 0x165667b1) + (a << 5);
    a = (a + 0xd3a2646c) ^ (a << 9);
    a = (a + 0xfd7046c5) + (a << 3);
    a = (a ^ 0xb55a4f09) ^ (a >> 16);
    return a;
}

/**
 * murmur
 */
uint hash_murmur(uint a) {
    uint m = 0x5bd1e995;
    uint r = 24;
    uint h = 64684;
    uint k = a;
    k *= m;
    k ^= (k >> r);
    k *= m;
    h *= m;
    h ^= k;
    return h;
}

// Random number generation using pcg32i_random_t, using inc = 1.
uint step_rng(uint rngState) { return rngState * 747796405 + 1; }

/**
 * Random Number generator
 * pcg32i_random_t based.
 * @ref: https://www.pcg-random.org/index.html
 * @ref: https://nvpro-samples.github.io/vk_mini_path_tracer/index.html#perfectlyspecularreflections/refactoringintersectioninformation
 */
struct RandomSampler {
    uint state;

    [mutating]
    uint next_uint() {
        state = step_rng(state);
        uint word = ((state >> ((state >> 28) + 4)) ^ state) * 277803737;
        word = (word >> 22) ^ word;
        return word;
    }

    [mutating]
    float next_float() {
        uint word = next_uint();
        return float(word) / 4294967295.0f;
    }

    [mutating]
    float2 next_float2() { return float2(next_float(), next_float()); }

    [mutating]
    float3 next_float3() { return float3(next_float(), next_float(), next_float()); }

    [mutating]
    Array<float, n> next_floatn<let n : int>() {
        Array<float, n> result;
        [ForceUnroll]
        for (int i = 0; i < n; i++)
            result[i] = next_float();
        return result;
    }
};

RandomSampler init_random_sampler(uint threadIndex, uint frameIndex) {
    RandomSampler r;
    r.state = frameIndex + hash_crng(threadIndex);
    return r;
}

RandomSampler init_random_sampler(uint2 pixelPos, uint frameIndex) {
    RandomSampler r;
    r.state = frameIndex + hash_crng((pixelPos.x << 16) | pixelPos.y);
    return r;
}

RandomSampler init_random_sampler(uint2 index, uint frameIndex, uint pass) {
    return init_random_sampler(index, frameIndex + pass * 13 * 17);
}
}

#endif // _SIBYLENGINE_RANDOM_HLSLI_