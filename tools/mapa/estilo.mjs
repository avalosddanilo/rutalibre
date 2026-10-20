// Genera los estilos del mapa base (claro y oscuro) a partir de los de
// Protomaps. Ver docs/mapa.md para cuándo y cómo se corre.
//
//   npm i @protomaps/basemaps@5.1.0
//   node tools/mapa/estilo.mjs 2026-10-20
import { layers, namedFlavor } from '@protomaps/basemaps';
import fs from 'node:fs';

const fecha = process.argv[2];
if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha ?? '')) {
  console.error('Uso: node tools/mapa/estilo.mjs AAAA-MM-DD (la fecha de los datos)');
  process.exit(1);
}

for (const [archivo, sabor] of [['claro', 'light'], ['oscuro', 'dark']]) {
  const estilo = {
    version: 8,
    name: `Ruta Libre ${archivo}`,
    // Entra en la identidad del tema: con datos nuevos, nada viejo se reusa.
    modified: fecha,
    sources: {
      // La URL no se usa: la app sirve esta fuente desde el asset.
      protomaps: { type: 'vector', url: 'pmtiles://asset', attribution: '© OpenStreetMap contributors' },
    },
    // Sin `sprite` ni `glyphs`: los nombres los dibuja Flutter y los íconos
    // de lugares no van (el mapa ya tiene las paradas, que es lo que importa).
    layers: layers('protomaps', namedFlavor(sabor), { lang: 'es' }),
  };
  fs.writeFileSync(`assets/map/estilo-${archivo}.json`, JSON.stringify(estilo) + '\n');
  console.log(`assets/map/estilo-${archivo}.json: ${estilo.layers.length} capas`);
}
