# Aportes de campo

Lo que cuenta la gente que se toma el colectivo, contrastado contra los datos
que la app ya tiene. Un aporte entra acá **con fecha y con quién lo dijo**, y
se anota si se verificó o no — la misma regla que `docs/horarios.md`.

Que alguien te cuente un recorrido no lo hace un dato: lo hace una pista.
Contrastarla contra la geometría que ya está en el repo cuesta diez minutos y
dice exactamente qué falta.

---

## Línea a Colonia Benítez y Margarita Belén ("la Bermejo")

**Fuente**: un vecino, de memoria, 2026-09-18. La empresa **avisa los cambios
de recorrido por su página de Facebook** — ese es el canal a seguir, y la
razón por la que el dato de OSM se puede quedar viejo sin que nadie se entere.
**Sin verificar** contra la empresa.

### Lo que contó, tramo por tramo (salida desde Resistencia)

1. Sale de **Pueyrredón al 50**, atrás de la Casa de Gobierno, frente al
   gimnasio, a media cuadra de la 25.
2. Dobla en **Marcelo T. de Alvear**, hace una cuadra.
3. Izquierda en **Remedios de Escalada**.
4. En la esquina de la Shell (**Remedios de Escalada y 25 de Mayo**) dobla a
   la derecha.
5. Agarra **toda 25 de Mayo** hasta el triángulo.
6. En el triángulo dobla a la derecha, pasa por las canchitas de fútbol hasta
   **Mascardi**.
7. En Mascardi dobla a la derecha y agarra la ruta. **De ahí en más no tiene
   paradas.**

La vuelta **no la sabemos**: es justo lo que falta.

### Qué dicen los datos que ya tenemos

La línea existe en el repo: `RES-CB`, "Colonia Benítez", red
`interurbano-chaco`, con ida y vuelta importadas de las relations de OSM
14449326 y 14449325.

Midiendo el relato contra esa geometría (distancia punto-a-segmento, no a los
vértices, porque el trazado está simplificado a 5 m):

| Punto del relato | Distancia a la ida | Distancia a la vuelta |
|---|---|---|
| Pueyrredón al 50 | 601 m | 363 m |
| Marcelo T. de Alvear al 100 | 743 m | 536 m |
| Remedios de Escalada al 100 | 511 m | 286 m |
| Av. 25 de Mayo al 200 | 598 m | 383 m |
| **Av. 25 de Mayo al 900** | **10 m** | **20 m** |
| **Av. 25 de Mayo al 1500** | **5 m** | **15 m** |
| Av. 25 de Mayo al 2600 | 110 m | 121 m |

Dos conclusiones, y son distintas:

1. **De 25 de Mayo al 900 para el norte, el relato y OSM coinciden** (5 a
   20 m es "es la misma calle"). Esa parte está bien mapeada.
2. **El tramo del centro NO está.** Nuestra ida arranca en **Av. Moreno y
   Santa María de Oro** (a 15 m del primer punto del trazado), no en
   Pueyrredón al 50. Todo lo que el vecino describe entre la Casa de Gobierno
   y 25 de Mayo al 900 —los pasos 1 a 4— cae a 300–750 m de lo que dibuja la
   app. O el recorrido cambió, o esa punta nunca se mapeó en OSM.

Y una tercera, aparte: **Margarita Belén no está en los datos**. El punto más
al norte de la línea es −27.3129, que es Colonia Benítez. El bbox del
importador (`tools/osm_import.dart`) corta en **−27.32**, y Margarita Belén
está en ≈ −27.27: aunque alguien la mapee en OSM, hoy el importador no la
bajaría. Sumarla es mover el borde norte del bbox en los cuatro
importadores.

### Cómo se arregla (y cómo NO)

El arreglo va **en OpenStreetMap**, no en el repo: así lo arreglan la app, el
que use OsmAnd y cualquier otro que venga después. Después se corre
`dart run tools/osm_import.dart` y el cambio entra solo.

> ⚠️ **No se calca de Google Maps.** Ni el trazado, ni las paradas, ni
> "mirando" el mapa de Google para dibujar en OSM. Está prohibido por los
> términos de Google y contamina el dato: si entra, hay que borrarlo todo y
> se pierde el trabajo. Esto no es un tecnicismo — es la razón por la que OSM
> se puede usar gratis en esta app.

Las dos formas que **sí** sirven, en orden de facilidad:

1. **Grabar el viaje.** Tomarse el colectivo con una app de GPS que exporte
   **GPX** (OsmAnd, GPSLogger, Organic Maps). El archivo se sube a OSM como
   traza y se dibuja el recorrido siguiéndola. Es lo más confiable y de paso
   resuelve **la vuelta**, que es lo que no sabemos.
2. **Dibujarlo en el editor iD** (editar en openstreetmap.org), sobre las
   imágenes aéreas que el propio editor ofrece — esas están habilitadas.
   Sirve para las esquinas que uno conoce de memoria.

Si el aporte es "las paradas de tal tramo", conviene mapear cada una como
`highway=bus_stop`: el importador las levanta y las ordena solo,
proyectándolas sobre el trazado.

### Pendiente

- [ ] La vuelta, completa.
- [ ] Confirmar si el tramo del centro es un cambio de recorrido (mirar la
      página de Facebook de la empresa, que es donde lo avisan) o un hueco de
      mapeo de siempre.
- [ ] Margarita Belén: mapear y mover el borde norte del bbox.
