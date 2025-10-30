shader_type canvas_item;

// ---------- Réglages principaux ----------
uniform vec2  camera_offset     = vec2(0.0, 0.0); // position monde de la Camera2D (envoyée par GDScript)
uniform float parallax          : hint_range(0.0, 2.0) = 0.4; // 0 = fixe au monde, 1 = suit pile la cam (fond "collé")
uniform float speed             : hint_range(0.0, 400.0) = 60.0;  // défilement (vers le bas)
uniform float global_scale      : hint_range(0.25, 4.0)  = 1.0;   // zoom global
uniform float brightness        : hint_range(0.2, 3.0)   = 1.0;   // gain
uniform float twinkle_strength  : hint_range(0.0, 1.0)   = 0.25;  // intensité scintillement
uniform float twinkle_speed     : hint_range(0.1, 12.0)  = 3.0;   // vitesse scintillement
uniform float seed              : hint_range(0.0, 999.0) = 1337.0;

// "Pleiiiins" d'étoiles : 3 octaves * 5 candidats/cellule = 15 étoiles potentielles par pixel
// Ajuste ces facteurs pour ENCORE plus (au prix des perfs)
uniform vec3 octave_density = vec3(1.0, 1.0, 1.0); // poids par octave
uniform vec3 octave_scale   = vec3(1.00, 1.75, 3.00);
uniform vec3 octave_speed   = vec3(1.00, 0.65, 0.40);
uniform vec3 octave_size    = vec3(0.90, 0.75, 0.60); // taille relative (octaves lointaines = plus petites)

// teintes légerement variées
uniform vec3 color_a = vec3(1.0, 1.0, 1.0);
uniform vec3 color_b = vec3(0.78, 0.86, 1.0);

// ---------- Utils ----------
float hash21(vec2 p){
    p = fract(p * vec2(443.8975, 441.423));
    p += dot(p, p + 23.345);
    return fract(p.x * p.y);
}
vec2 hash22(vec2 p){
    float n = hash21(p);
    return vec2(n, hash21(p + n));
}

// profil d’étoile (cœur + halo doux)
float star_profile(float d, float s){
    // s = taille "noyau"
    float core = smoothstep(s, 0.0, d);
    float halo = smoothstep(2.5*s, 0.0, d) * 0.25;
    return core + halo;
}

// une "cellule" produit plusieurs candidats (étoiles) — dense mais cheap
float star_candidates(vec2 uv, float cell, float size_mul, float t, out float color_mix){
    vec2 g = floor(uv / cell);
    float acc = 0.0;
    float mix_acc = 0.0;

    // 5 candidats par cellule (réglage fixe pour le GPU)
    // On "décale" l’UV pour varier les positions locales
    for (int i = 0; i < 5; i++){
        vec2 jitter = vec2(float(i) * 11.13, float(i) * 7.77);
        vec2 r = hash22(g + seed + jitter);
        vec2 star_pos = (g + r) * cell;

        float d = length(uv - star_pos);

        // scintillement par-étoile
        float phase = r.x * 6.28318;
        float tw = 1.0 + twinkle_strength * (sin(t * twinkle_speed + phase) * 0.5 + 0.5);

        // probabilité d'apparition (seuil) -> BEAUCOUP d’étoiles
        float appear = step(0.12, r.y); // plus petit -> plus d’étoiles
        float s = star_profile(d, size_mul) * tw * appear;

        acc += s;
        mix_acc += s * r.x; // sert à mixer la teinte sur ce lot
    }

    color_mix = (acc > 0.0) ? clamp(mix_acc / (acc + 1e-5), 0.0, 1.0) : 0.0;
    return acc;
}

// une octave (échelle + vitesse)
float star_octave(vec2 uv, float scale_mul, float speed_mul, float density_mul, float size_mul, float t, out float mix_out){
    vec2 luv = uv * scale_mul;
    luv.y += t * speed * speed_mul;

    // cellule fine -> plus d’étoiles
    float cell = mix(110.0, 36.0, clamp(density_mul, 0.0, 1.0));
    float layer_mix;
    float s = 0.0;

    // On échantillonne la cellule et deux variantes décalées pour casser les motifs
    float m0; s += star_candidates(luv,            cell, 0.9 * size_mul, t, m0);
    float m1; s += star_candidates(luv +  37.7,    cell, 1.0 * size_mul, t, m1);
    float m2; s += star_candidates(luv + -19.3, cell*0.85, 0.8 * size_mul, t, m2);

    // moyenne des mixes de couleur
    layer_mix = (m0 + m1 + m2 > 0.0) ? (m0*m0 + m1*m1 + m2*m2) / ((m0 + m1 + m2) + 1e-5) : 0.0;
    mix_out = layer_mix;
    return s;
}

void fragment(){
    // UV isotropes en unités "écran"
	vec2 uv = SCREEN_UV * 400.0;        // la version simple que tu utilises déjà
	uv -= vec2(-camera_offset.x, -camera_offset.y) * parallax;     // <<< AJOUT : décale en fonction de la caméra

    float t = TIME;

    float mix0; float s0 = star_octave(uv, octave_scale.x, octave_speed.x, octave_density.x, octave_size.x, t, mix0);
    float mix1; float s1 = star_octave(uv, octave_scale.y, octave_speed.y, octave_density.y, octave_size.y, t, mix1);
    float mix2; float s2 = star_octave(uv, octave_scale.z, octave_speed.z, octave_density.z, octave_size.z, t, mix2);

    // teintes
    vec3 c0 = mix(color_a, color_b, mix0);
    vec3 c1 = mix(color_b, color_a, mix1);
    vec3 c2 = mix(color_a, color_b, mix2);

    vec3 col = c0 * s0 + c1 * s1 + c2 * s2;

    // vignette subtile (évite un mur uniforme)
    vec2 uv01 = SCREEN_UV - 0.5;
    float vignette = 1.0 - smoothstep(0.6, 0.96, length(uv01));
    col *= mix(0.9, 1.0, vignette);

    COLOR = vec4(col * brightness, 1.0);
}
