package cl.rednorte.bff_gateway.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.datasource.init.ScriptUtils;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.Map;

/**
 * Endpoint oculto SOLO para entornos dev/demo.
 * Activo únicamente con el perfil Spring: dev o demo.
 *
 * POST /interno/seed/cargar
 *   Header: X-Seed-Token: <valor de app.seed.token en application-dev.properties>
 *
 * NO exponer en producción.
 */
@RestController
@RequestMapping("/interno/seed")
@Profile({"dev", "demo"})
public class SeedController {

    @Autowired
    private DataSource dataSource;

    /**
     * Token secreto configurado en application-dev.properties:
     *   app.seed.token=rednorte-seed-2026
     */
    @Value("${app.seed.token:rednorte-seed-2026}")
    private String seedToken;

    /**
     * Carga el script SQL de datos ficticios.
     * Requiere header X-Seed-Token correcto.
     */
    @PostMapping("/cargar")
    public ResponseEntity<Map<String, String>> cargarSeed(
            @RequestHeader(value = "X-Seed-Token", required = false) String token) {

        if (token == null || !token.equals(seedToken)) {
            return ResponseEntity.status(403)
                    .body(Map.of(
                        "status",  "error",
                        "mensaje", "Token inválido o ausente"
                    ));
        }

        try (Connection conn = dataSource.getConnection()) {
            ClassPathResource script = new ClassPathResource("db/seed_datos_ficticios.sql");
            ScriptUtils.executeSqlScript(conn, script);
            return ResponseEntity.ok(Map.of(
                "status",  "ok",
                "mensaje", "Seed ejecutado correctamente"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(Map.of(
                        "status",  "error",
                        "mensaje", "Error al ejecutar seed: " + e.getMessage()
                    ));
        }
    }

    /**
     * Verifica que el endpoint esté activo (útil para probar desde Postman).
     */
    @GetMapping("/ping")
    public ResponseEntity<Map<String, String>> ping(
            @RequestHeader(value = "X-Seed-Token", required = false) String token) {

        if (token == null || !token.equals(seedToken)) {
            return ResponseEntity.status(403)
                    .body(Map.of("status", "error", "mensaje", "Token inválido"));
        }
        return ResponseEntity.ok(Map.of(
            "status",  "ok",
            "mensaje", "Seed endpoint activo",
            "perfil",  "dev/demo"
        ));
    }
}
