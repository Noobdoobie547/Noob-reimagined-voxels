#ifndef AURELIA_AURORA_H
#define AURELIA_AURORA_H

#include <config.sh>

float aureliaAuroraNoise(sampler2D tex, highp vec2 p) {
  highp vec2 q = floor(p * 128.0) / 128.0 + 2.0 / 128.0;
  return texture2D(tex, q).r;
}

vec3 aureliaAurora(sampler2D tex, vec3 dir, highp float time, float dither) {
  float up = clamp(dir.y, 0.0, 1.0);
  float visibility = sqrt(clamp(up * 4.5 - 0.25, 0.0, 1.0));
  visibility *= 8.0 - up * 0.9;
  if (visibility <= 1.0) {
    return vec3_splat(0.0);
  }

  highp vec2 wpos = dir.xz / max(dir.y, 0.1);
  highp vec2 drift = vec2(time * AURELIA_AURORA_SPEED, 0.0);

  vec3 aurora = vec3_splat(0.0);
  float steps = float(AURELIA_AURORA_STEPS);
  float total = steps + 10.0;

  for (int i = 0; i < AURELIA_AURORA_STEPS; i++) {
    float current = (float(i) + dither + 10.0) / total;
    current *= current;
    float inv = 1.0 - current;

    highp vec2 planePos = (wpos * (0.9 + current) * 10.0 + drift) * 0.003;

    float n = aureliaAuroraNoise(tex, planePos);
    float ridge = 1.0 - abs(n - 0.4);
    ridge *= ridge;
    ridge *= ridge;
    ridge *= ridge;

    float a1 = aureliaAuroraNoise(tex, planePos * 0.5 + time * AURELIA_AURORA_ANIM);
    float a2 = aureliaAuroraNoise(tex, planePos * 0.8 - time * AURELIA_AURORA_ANIM);
    ridge *= mix(a1, a2, 0.5);

    float inv4 = inv * inv;
    inv4 *= inv4;
    aurora += ridge * inv * mix(AURELIA_AURORA_FAR, AURELIA_AURORA_NEAR, inv4);
  }

  return aurora * (0.8 * visibility / steps);
}

#endif
