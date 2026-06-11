package cl.rednorte.bff_gateway.dto.response;

import cl.rednorte.bff_gateway.enums.EstadoSolicitud;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class SolicitudResponse {

    private Long id;
    private String rutPaciente;
    private String especialidad;
    private Integer prioridad;
    private EstadoSolicitud estado;
    private LocalDateTime fechaRegistro;
}
