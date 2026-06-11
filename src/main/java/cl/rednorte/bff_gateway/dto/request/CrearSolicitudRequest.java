package cl.rednorte.bff_gateway.dto.request;

import cl.rednorte.bff_gateway.enums.NivelUrgencia;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CrearSolicitudRequest {

    @NotBlank(message = "El RUT del paciente es obligatorio")
    private String rutPaciente;

    @NotNull(message = "La especialidad es obligatoria")
    private Long especialidadId;

    @NotBlank(message = "El diagnóstico es obligatorio")
    private String diagnostico;

    @NotNull(message = "Debe indicar si es GES")
    private Boolean esGES;

    private String patologiaGES;

    @NotNull(message = "El nivel de urgencia es obligatorio")
    private NivelUrgencia nivelUrgencia;

    @NotNull(message = "Debe indicar si es vulnerable")
    private Boolean esVulnerable;

    private Long tipoVulnerabilidadId;
}
