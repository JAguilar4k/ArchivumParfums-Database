# ArchivumParfums · Base de datos

Esquema y aprovisionamiento de PostgreSQL 18 para [ArchivumParfums](https://github.com/JAguilar4k/ArchivumParfums-Hexagonal). Este repositorio versiona las migraciones de Laravel, los roles de PostgreSQL y el modelo de datos.

| Archivo | Responsabilidad |
|---|---|
| `*_*.php` | Migraciones reversibles con tablas, restricciones, extensiones, funciones y políticas de seguridad a nivel de fila. |
| [`roles.sql`](roles.sql) | Creación inicial de `archivum_owner`, `archivum_app` y las bases de desarrollo y pruebas. |
| [`docs/database.md`](docs/database.md) | Convenciones del esquema, roles y aislamiento entre tiendas. |
| [`docs/data-model.md`](docs/data-model.md) | Diagrama, tablas y justificación de la normalización. |

## Instalación

El backend fija un commit de este repositorio como submódulo en `archivum-api-hexagonal/database/migrations`. Cloná el backend con el submódulo o inicializalo desde un checkout existente.

```bash
git clone --recurse-submodules https://github.com/JAguilar4k/ArchivumParfums-Hexagonal.git
cd ArchivumParfums-Hexagonal
git submodule update --init --recursive
```

Seguí la instalación del [backend](https://github.com/JAguilar4k/ArchivumParfums-Hexagonal/tree/main/archivum-api-hexagonal) para configurar `.env`, Composer y las conexiones. Si aprovisionás un servidor nuevo manualmente, ejecutá `roles.sql` una sola vez como superusuario, desde la raíz de este repositorio.

```bash
psql -U postgres -v ON_ERROR_STOP=1 -v owner_password='…' -v app_password='…' -f roles.sql
```

Desde `archivum-api-hexagonal`, ejecutá las migraciones con el rol dueño.

```bash
php artisan migrate --database=pgsql_admin
```

PostgreSQL garantiza la integridad, el aislamiento por tienda y las restricciones de concurrencia. El backend aplica su filtro por `business_id`, implementa los casos de uso y mantiene las fábricas y los datos ficticios de prueba. La [especificación](https://github.com/JAguilar4k/ArchivumParfums-Hexagonal/blob/main/docs/especificacion.md) define las reglas del negocio.

## Cambios del esquema

Trabajá cada cambio en una rama de este repositorio, asociado a un issue y a un PR revisado. Conservá el nombre de cada migración aplicada. Después de integrar el cambio de esquema, actualizá el commit del submódulo en un PR del [backend](https://github.com/JAguilar4k/ArchivumParfums-Hexagonal) con cualquier cambio de aplicación que lo use.

El job `Database` comprueba la sintaxis PHP y los roles, la propiedad de las bases y los permisos en PostgreSQL 18. El CI del backend aplica las migraciones fijadas y ejecuta Pest con el rol de la aplicación, incluidas las pruebas de seguridad por fila, concurrencia y reversibilidad. Para validar un cambio de esquema antes de integrar, usá su commit en el submódulo de una copia local del backend y ejecutá `composer test` con una base de pruebas.

## Uso de IA

Codex preparó la extracción del historial y la configuración inicial de este repositorio, conservó los archivos de migración y adaptó la documentación. Verificó que las 40 migraciones coinciden con el backend de origen y que pasan el análisis de sintaxis. También ejecutó el aprovisionamiento y las consultas de permisos en una instancia aislada de PostgreSQL 18.6. El equipo revisa el cambio en el [issue de coordinación](https://github.com/JAguilar4k/ArchivumParfums-Hexagonal/issues/338).
