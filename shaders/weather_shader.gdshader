shader_type canvas_item;

// Weather blend targets (set by WeatherFilmLayer each frame via lerp)
uniform float blend_clear    : hint_range(0.0, 1.0) = 1.0;
uniform float blend_cloudy   : hint_range(0.0, 1.0) = 0.0;
uniform float blend_rain     : hint_range(0.0, 1.0) = 0.0;
uniform float blend_storm    : hint_range(0.0, 1.0) = 0.0;
uniform float blend_fog      : hint_range(0.0, 1.0) = 0.0;
uniform float blend_windy    : hint_range(0.0, 1.0) = 0.0;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 screen = texture(screen_texture, uv);

    // ---- Film grain (always present, subtle) ----
    float base_grain = 0.018;
    float grain_strength = base_grain
        + blend_cloudy * 0.012
        + blend_rain   * 0.022
        + blend_storm  * 0.045
        + blend_fog    * 0.008;
    float grain = fract(sin(dot(uv + TIME * 0.07, vec2(127.1, 311.7))) * 43758.5453);
    grain = (grain - 0.5) * grain_strength;

    // ---- Vignette (always present) ----
    float base_vig = 0.18;
    float vig_strength = base_vig
        + blend_cloudy * 0.08
        + blend_storm  * 0.22
        + blend_fog    * 0.05;
    vec2 vig_uv = uv * (1.0 - uv.yx);
    float vignette = pow(vig_uv.x * vig_uv.y * 12.0, vig_strength);
    vignette = clamp(vignette, 0.0, 1.0);

    // ---- Color grade per weather ----
    // Clear: slight warmth
    vec4 grade_clear   = vec4(1.02, 0.99, 0.95, 1.0);
    // Cloudy: desaturated cool
    vec4 grade_cloudy  = vec4(0.88, 0.90, 0.95, 1.0);
    // Rain: blue-grey
    vec4 grade_rain    = vec4(0.78, 0.83, 0.92, 1.0);
    // Storm: dark, desaturated, slight green-grey
    vec4 grade_storm   = vec4(0.62, 0.65, 0.70, 1.0);
    // Fog: washed-out whites, very low contrast
    vec4 grade_fog     = vec4(0.95, 0.95, 0.97, 1.0);
    // Windy: cool and slightly hazy
    vec4 grade_windy   = vec4(0.86, 0.90, 0.96, 1.0);

    vec4 color_grade =
        grade_clear  * blend_clear  +
        grade_cloudy * blend_cloudy +
        grade_rain   * blend_rain   +
        grade_storm  * blend_storm  +
        grade_fog    * blend_fog    +
        grade_windy  * blend_windy;

    // ---- Saturation ----
    float sat_mult = 1.0
        - blend_cloudy * 0.15
        - blend_storm  * 0.35
        - blend_fog    * 0.20;
    float lum = dot(screen.rgb, vec3(0.299, 0.587, 0.114));
    vec3 graded = mix(vec3(lum), screen.rgb * color_grade.rgb, sat_mult);

    // ---- Fog lift: blend screen toward white ----
    float fog_lift = blend_fog * 0.30;
    graded = mix(graded, vec3(0.95), fog_lift);

    // ---- Storm: chromatic aberration on edges ----
    float ca_strength = blend_storm * 0.004;
    float r = texture(screen_texture, uv + vec2(ca_strength, 0.0)).r;
    float b = texture(screen_texture, uv - vec2(ca_strength, 0.0)).b;
    graded.r = mix(graded.r, r, blend_storm);
    graded.b = mix(graded.b, b, blend_storm);



    // ---- Wind horizontal edge smear ----
  	if (blend_windy > 0.01) {
        float edge = smoothstep(0.3, 0.0, abs(uv.x - 0.5));
        float smear_offset = blend_windy * 0.002 * edge;
        vec3 smeared = texture(screen_texture, uv + vec2(smear_offset, 0.0)).rgb;
        graded = mix(graded, smeared, blend_windy * edge * 0.15);
    }

    // ---- Apply vignette and grain ----
    graded *= vignette;
    graded += grain;

    COLOR = vec4(clamp(graded, 0.0, 1.0), 1.0);
}