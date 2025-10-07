import '../models/trip.dart';

const mockTrips = <Trip>[
  Trip(
    driverName: 'Mariana Souza',
    origin: 'FACCAT',
    destination: 'Centro de Taquara',
    whenLabel: 'Hoje • 19:00',
    seats: 3,
    note: 'Vou pela Av. Sebastião Amoretti',
  ),
  Trip(
    driverName: 'João Pedro',
    origin: 'Igrejinha',
    destination: 'FACCAT',
    whenLabel: 'Hoje • 18:45',
    seats: 2,
  ),
  Trip(
    driverName: 'Ana Clara',
    origin: 'Parobé',
    destination: 'FACCAT',
    whenLabel: 'Amanhã • 07:30',
    seats: 1,
  ),
  Trip(
    driverName: 'Rafa Lima',
    origin: 'FACCAT',
    destination: 'Gravataí (Centro)',
    whenLabel: 'Hoje • 22:00',
    seats: 2,
    note: 'Saio do bairro Figueiras',
  ),
];
