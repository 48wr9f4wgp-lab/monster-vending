# MONSTER VENDING — Art Bible v0.1

Visual Canon: `monster-vending-visual-target-v1.png`

## Visual thesis
**Cute Weird × Toy Machine × Bright Creature Lab × Living Collection**

The screen should feel like a friendly toy aisle, a slightly mysterious creature lab, and a lovable pet room at once.

## Canonical visual formula
**Big Friendly Machine + Weird-Cute Creatures + Tactile Toy UI + Living Habitat + Controlled Colorfulness**

## Hierarchy
1. Monster / reveal
2. Vending Machine
3. VEND CTA
4. Habitat / owned collection
5. HUD / progress

## Machine
- Rounded, chunky, toy-like, friendly mechanical forms
- Purple primary body; deep violet shadows; lavender highlights
- Big eyes/horns/mouth-like capsule window; clear face-like silhouette
- Golden-yellow VEND button is the strongest CTA color
- Machine is the second main character and never fully static
- Mechanical motion should feel heavier than creature motion

## Creatures
- Approx. 70% cute / 30% weird
- Head-dominant proportions, strong silhouette, clear face at small size
- Each species needs one body gimmick / weird element and one signature reaction
- Avoid photoreal anatomy, gore, body horror and realistic insect detail
- Clean color blocks and simple patterns over noisy textures
- Shared production families: Blob / Biped / Quadruped / Float

## Habitat
- Cozy creature display room, never an industrial cage
- Softer/organic visual language than the Machine
- Rounded shelves/platforms, plants, lamps, toy furniture
- Decoration exists primarily to provoke creature reactions
- Creature saturation > background saturation
- Capacity 4 and capacity 8 must look visibly different

## Palette roles
- Machine: Purple / Violet
- Primary CTA: Warm Golden Yellow
- Mechanical void / secondary UI: Dark Navy
- Creatures/capsules/rewards: Cyan, Mint, Coral, Magenta, Orange, Electric Blue, Soft Pink
- Background: lower-saturation Blue/Cream/Green/Warm Neutral

Do not make the entire screen rainbow. Reserve strong saturation for creatures, capsules, rewards and CTA.

## Materials
- Machine: glossy molded plastic + powder-coated metal
- Creatures: soft vinyl / plush / jelly-like stylization
- Capsule: translucent acrylic/glass feel
- Habitat props: matte wood/fabric/soft toy materials
- Physically believable but not photoreal; target toy-commercial cleanliness

## Lighting
- Bright soft studio main light
- Warm interior/fill light
- Clear catchlights in creature eyes
- Bloom only for meaningful reward states such as Rare+, Neon Machine, upgrade or portal
- Soft contact shadows for creatures; slightly stronger machine grounding

## UI
- Rounded rectangles, thick borders, tactile depth
- Heavy rounded display type for VEND/NEW/major reward
- Rounded sans for normal UI
- Chunky icons with readable silhouettes
- Do not use flat minimalist UI as the primary visual language

## Rarity
Never communicate rarity by color alone. Combine color, frame/pattern, particles, sound, haptic and reveal motion. Legendary should make the Machine behave abnormally, not merely turn gold.

## Capsule
- Transparent/translucent toy capsule or egg-like custom silhouette
- Must visibly imply "something is inside"
- Avoid Poké Ball-like horizontal split/iconography

## Motion
- UI: snappy slide, squash, overshoot
- Creatures: bouncy/squashy/wobbly
- Machine: weighted mechanical movement
- Camera: stable normally; small reward pushes only
- Particles must never obscure the creature silhouette

## Performance
Quality must degrade gracefully on mobile by reducing particle count, bloom, dynamic lights, shadow quality, reflections and background agents. Do not change core gameplay under low-end mode.

## Visual acceptance tests
- Thumbnail: species identifiable at small size
- Silhouette: species identifiable in black
- Grayscale: CTA and hierarchy still readable
- Blur: Machine / Monster / VEND remain dominant
- Start vs 10 min: obvious world growth without explanation

## Do
Make monsters readable and lovable; characterize the Machine; keep color hierarchy controlled; make ownership visible in Habitat; show growth physically.

## Don't
Photoreal monsters/machine; generic industrial vending machine; screen-filling particles; tiny text/excessive icons; identical creature faces; gold-only Legendary treatment; competitor-specific creature/capsule/UI/animation language.
