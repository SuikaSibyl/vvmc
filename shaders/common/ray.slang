#ifndef _SIBYLENGINE_RAY_HLSLI_
#define _SIBYLENGINE_RAY_HLSLI_

struct Ray {
    float3  origin;
    float   tMin;
    float3  direction;
    float   tMax;

    float3 at(float t) { return origin + t * direction; }

    RayDesc to_desc() {
        RayDesc raydesc = {};
        raydesc.Origin = origin;
        raydesc.Direction = direction;
        raydesc.TMin = tMin;
        raydesc.TMax = tMax;
        return raydesc;
    }
};

#endif // _SIBYLENGINE_RAY_HLSLI_