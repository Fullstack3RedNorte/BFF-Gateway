package cl.rednorte.bff_gateway.dto.response;

import cl.rednorte.bff_gateway.enums.EstadoSolicitud;
import cl.rednorte.bff_gateway.enums.NivelUrgencia;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class SolicitudDetalleResponse {

    private Long id;
    private String rutPaciente;
    private String rutFuncionario;
    private String especialidad;
    private String diagnostico;
    private Boolean esGES;
    private String patologiaGES;
    private NivelUrgencia nivelUrgencia;
    private Boolean esVulnerable;
    private String tipoVulnerabilidad;
    private Integer prioridad;
    private EstadoSolicitud estado;
    private LocalDateTime fechaRegistro;
    private LocalDateTime fechaActualizacion;
    private List<HistorialEstadoResponse> historial;
}