//Requisito:
//Manter abastecimento
//O sistema deve disponibilizar funcionalidades para registro e visualização da entidade de abastecimento, ela deve conter os seguintes atributos:
//Placa
//Data/hora
//KM
//Combustível
//Valor por litro
//Litros abastecidos
//Total(R$)

class FuelModel {
  final String id;
  final String plate;
  final DateTime date;
  final int km;
  final String fuel;
  final double valuePerLiter;
  final double liters;
  final double total;

  FuelModel({
    required this.id,
    required this.plate,
    required this.date,
    required this.km,
    required this.fuel,
    required this.valuePerLiter,
    required this.liters,
    required this.total,
  });

  factory FuelModel.fromJson(Map<String, dynamic> json) {
    return FuelModel(
      id: json['id'],
      plate: json['plate'],
      date: json['date'],
      km: json['km'],
      fuel: json['fuel'],
      valuePerLiter: json['valuePerLiter'],
      liters: json['liters'],
      total: json['total'],
    );
  }
}