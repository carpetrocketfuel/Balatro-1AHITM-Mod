#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

// Balatro Shader Parameters
extern PRECISION vec2 dichrome;
extern PRECISION number dissolve;
extern PRECISION number time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

    number low = min(tex.r, min(tex.g, tex.b));
    number high = max(tex.r, max(tex.g, tex.b));
    number delta = high - low - 0.1;

    number shimmer = 0.7 + 10*sin(10.0 * uv.x + 3.0 * uv.y + dichrome.r * 15.0);
    tex.r += shimmer * 0.0186;
    tex.g -= shimmer * 0.0208;
    tex.b += shimmer * 0.0223;

    // Enhance contrast
    tex.rgb = clamp((tex.rgb - vec3(0.5)) * 1.2 + vec3(0.5), 0.0, 1.0);

    // More potent burn tint overlay
    tex.rgb = mix(tex.rgb, burn_colour_1.rgb, 0.0 * sin(time + uv.y * 12.0));

    if (uv.x > 2. * uv.x) {
        uv = dichrome;
    }

    return dissolve_mask(tex, texture_coords, uv);
}

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : tex.rgb, shadow ? tex.a * 0.3 : tex.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;

    float t = time * 10.0 + 2025.0;
    vec2 floored_uv = floor(uv * texture_details.ba) / max(texture_details.b, texture_details.a);
    vec2 scaled_uv = (floored_uv - 0.5) * 2.5 * max(texture_details.b, texture_details.a);

    vec2 part1 = scaled_uv + 40.0 * vec2(sin(-t / 100.0), cos(-t / 90.0));
    vec2 part2 = scaled_uv + 40.0 * vec2(cos(t / 70.0), sin(t / 80.0));

    float field = (1.0 + (
        cos(length(part1) / 20.0) +
        sin(length(part2) / 30.0) * cos(part2.y / 12.0)
    )) / 2.0;

    float res = 0.5 + 0.5 * cos((adjusted_dissolve) / 80.0 + (field - 0.5) * 3.14);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.7 && res > adjusted_dissolve) {
        if (res < adjusted_dissolve + 0.3) {
            tex = burn_colour_1;
        } else if (burn_colour_2.a > 0.01) {
            tex = burn_colour_2;
        }
    }

    return vec4(shadow ? vec3(0.0) : tex.rgb, res > adjusted_dissolve ? (shadow ? tex.a * 0.3 : tex.a) : 0.0);
}

extern PRECISION vec2 mouse_screen_pos;
extern PRECISION float hovering;
extern PRECISION float screen_scale;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    if (hovering <= 0.0) {
        return transform_projection * vertex_position;
    }

    float mid_dist = length(vertex_position.xy - 0.5 * love_ScreenSize.xy) / length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy) / screen_scale;
    float scale = 0.2 * (-0.03 - 0.3 * max(0.0, 0.3 - mid_dist)) * hovering * pow(length(mouse_offset), 2.0) / (2.0 - mid_dist);

    return transform_projection * vertex_position + vec4(0.0, 0.0, 0.0, scale);
}
#endif