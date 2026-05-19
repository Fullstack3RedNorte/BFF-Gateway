package cl.rednorte.bff_gateway.dto.response;

import cl.rednorte.bff_gateway.enums.EstadoSolicitud;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class HistorialEstadoResponse {

    private EstadoSolicitud estadoAnterior;
    private EstadoSolicitud estadoNuevo;
    private String motivo;
    private LocalDateTime fechaCambio;
    private String rutUsuarioResponsable;
}