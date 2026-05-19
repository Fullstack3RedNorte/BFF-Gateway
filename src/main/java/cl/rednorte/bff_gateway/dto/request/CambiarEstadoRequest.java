package cl.rednorte.bff_gateway.dto.request;

import cl.rednorte.bff_gateway.enums.EstadoSolicitud;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CambiarEstadoRequest {

    @NotNull(message = "El nuevo estado es obligatorio")
    private EstadoSolicitud nuevoEstado;

    private String motivo;
}