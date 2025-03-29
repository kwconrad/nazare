uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse; // Add mouse uniform
uniform float u_dotSize;
uniform float u_dotSpacing;
uniform float u_bounceAmount; // Controls bounce amplitude
uniform float u_bounceSpeed; // Controls bounce speed
uniform float u_waveFrequency; // Controls how tightly packed the wave is
varying vec2 vUv;

vec3 colorA = vec3(0.912,0.191,0.652);
vec3 colorB = vec3(1.000,0.777,0.052);

// Function to convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Function to convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main() {
  // Scale and shift UVs to pixel coordinates
  vec2 pixelCoords = vUv * u_resolution;

  // Warp effect based on mouse position
  vec2 mouseDist = pixelCoords - u_mouse * u_resolution;
  float warp = exp(-length(mouseDist) * 0.001); // Exponential falloff for warp effect
  pixelCoords += mouseDist * warp * 0.5; // Apply warp distortion

  // Calculate horizontal wave displacement
  // This creates a wave that travels horizontally across the screen
  float horizontalWave = sin(pixelCoords.x * u_waveFrequency - u_time * u_bounceSpeed) * u_bounceAmount;

  // Apply wave to position (vertically)
  pixelCoords.y += horizontalWave;

  // Calculate dot grid
  vec2 gridPos = mod(pixelCoords, u_dotSpacing) - u_dotSpacing/2.0;

  // Distance to center of each grid cell
  float dist = length(gridPos);

  // Create dot pattern using distance field
  float dotMask = 1.0 - smoothstep(u_dotSize - 1.0, u_dotSize, dist);

  // Apply color rotation
  float hueSpeed = 0.05;
  float hueShift = sin(u_time * hueSpeed) * 0.5 + 0.5;

  // Convert original colors to HSV
  vec3 colorAHsv = rgb2hsv(colorA);
  vec3 colorBHsv = rgb2hsv(colorB);

  // Apply hue rotation
  colorAHsv.x = fract(colorAHsv.x + hueShift);
  colorBHsv.x = fract(colorBHsv.x + hueShift);

  // Convert back to RGB
  vec3 shiftedColorA = hsv2rgb(colorAHsv);
  vec3 shiftedColorB = hsv2rgb(colorBHsv);

  // Mix colors based on position
  vec3 finalColor = mix(shiftedColorA, shiftedColorB, vUv.x);

  gl_FragColor = vec4(finalColor * dotMask, dotMask);
}
