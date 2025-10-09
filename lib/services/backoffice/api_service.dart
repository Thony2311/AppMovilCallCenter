import '../../models/backoffice/venta_model.dart';

class ApiService {
  // TODO: Conectar con backend real
  // Ahora devolvemos mock data
  Future<List<Venta>> fetchSales() async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    return [
      Venta(
        id: 1,
        cliente: "Cliente A",
        producto: "Producto X",
        agente: "Agente 1",
        fecha: "09/10/2025",
        duracion: "5 min",
        status: "auditada",
        monto: 150000.50,
        transcripcion: "El cliente aceptó la oferta sin objeciones.",
      ),
      Venta(
        id: 2,
        cliente: "Cliente B",
        producto: "Producto Y",
        agente: "Agente 2",
        fecha: "10/10/2025",
        duracion: "12 min",
        status: "pendiente",
        monto: 300000,
      ),
      Venta(
        id: 3,
        cliente: "Cliente C",
        producto: "Producto Z",
        agente: "Agente 3",
        fecha: "11/10/2025",
        duracion: "8 min",
        status: "reportada",
        monto: 120000,
        transcripcion: "El cliente colgó antes de finalizar la llamada.",
      ),
    ];
  }
}
