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

// Los colores propios, encima de los de Protomaps. La idea, en orden:
// 1. Que las LÍNEAS manden: verdes, agua y edificios apagados, para que el
//    color de cada línea sea lo que más se ve.
// 2. Que las calles se lean al sol, en la parada: bordes marcados y nombres
//    oscuros.
// 3. Que uno se ubique: las avenidas blancas y anchas, las rutas y el
//    puente en crema.
// 4. Que se vea Ruta Libre: el oscuro usa el negro de la marca (#161616).
const propios = {
  light: {
    background: '#d6d1c8',
    earth: '#e6e2da',
    park_a: '#dfe8df', park_b: '#cbe2cf',
    wood_a: '#dfe8df', wood_b: '#cbe2cf',
    scrub_a: '#e2e8e0', scrub_b: '#cfe2d3',
    water: '#b5d6e6',
    buildings: '#d9d3ca',
    pedestrian: '#e4dfd5',
    hospital: '#ece2e0', school: '#ebe5dc', industrial: '#e3e3e1',
    minor_casing: '#cbc4b8', minor_service_casing: '#d3cdc2', link_casing: '#c4bbac',
    major_casing_early: '#c4bbac', major_casing_late: '#c4bbac',
    highway: '#fff3d1', bridges_highway: '#fff3d1',
    highway_casing_early: '#e2cd96', highway_casing_late: '#e2cd96',
    bridges_highway_casing: '#e2cd96',
    roads_label_minor: '#6f6a66', roads_label_major: '#5c5753',
    address_label: '#6f6a66',
    subplace_label: '#7a756f', city_label: '#45413e',
  },
  dark: {
    background: '#101010',
    earth: '#161616',
    park_a: '#18201b', park_b: '#1a2a20',
    wood_a: '#18201b', wood_b: '#1a2a20',
    water: '#1b2a33',
    buildings: '#0f0f0f',
    minor_a: '#353535', minor_b: '#2e2e2e', major: '#424242', link: '#424242',
    highway: '#4d4636', bridges_highway: '#4d4636',
    roads_label_minor: '#8a8a8a', roads_label_major: '#a0a0a0',
    address_label: '#8a8a8a',
    subplace_label: '#7a7a7a', city_label: '#b0b0b0',
  },
};

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
    layers: layers('protomaps', { ...namedFlavor(sabor), ...propios[sabor] }, { lang: 'es' }),
  };
  fs.writeFileSync(`assets/map/estilo-${archivo}.json`, JSON.stringify(estilo) + '\n');
  console.log(`assets/map/estilo-${archivo}.json: ${estilo.layers.length} capas`);
}
