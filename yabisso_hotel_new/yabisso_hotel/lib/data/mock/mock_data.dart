import '../../core/constants/app_constants.dart';
import '../models/employee.dart';
import '../models/hotel.dart';
import '../models/order.dart';
import '../models/reservation.dart';
import '../models/room.dart';

/// Données de démonstration pour développer l'UI hors-ligne, sans backend.
/// À remplacer progressivement par les données réelles issues de SQLite / sync.
class MockData {
  MockData._();

  static const HotelProfile hotel = HotelProfile(
    id: 'htl_1',
    name: 'Yabisso Hôtel — Pointe-Noire',
    city: 'Pointe-Noire',
    country: 'Congo',
    roomCount: 42,
    floorCount: 4,
  );

  static final List<Room> rooms = [
    const Room(id: 'r101', number: '101', type: 'Simple', floor: 1, pricePerNight: 35000, status: RoomStatus.disponible),
    const Room(id: 'r102', number: '102', type: 'Double', floor: 1, pricePerNight: 45000, status: RoomStatus.occupee, currentGuestId: 'g1'),
    const Room(id: 'r103', number: '103', type: 'Double', floor: 1, pricePerNight: 45000, status: RoomStatus.nettoyage),
    const Room(id: 'r104', number: '104', type: 'Suite', floor: 1, pricePerNight: 90000, status: RoomStatus.reservee),
    const Room(id: 'r201', number: '201', type: 'Simple', floor: 2, pricePerNight: 35000, status: RoomStatus.disponible),
    const Room(id: 'r202', number: '202', type: 'Deluxe', floor: 2, pricePerNight: 65000, status: RoomStatus.occupee, currentGuestId: 'g2'),
    const Room(id: 'r203', number: '203', type: 'Double', floor: 2, pricePerNight: 45000, status: RoomStatus.maintenance),
    const Room(id: 'r204', number: '204', type: 'Suite', floor: 2, pricePerNight: 90000, status: RoomStatus.inspection),
    const Room(id: 'r301', number: '301', type: 'Deluxe', floor: 3, pricePerNight: 65000, status: RoomStatus.disponible),
    const Room(id: 'r302', number: '302', type: 'Simple', floor: 3, pricePerNight: 35000, status: RoomStatus.horsService),
  ];

  static final List<Reservation> reservations = [
    Reservation(
      id: 'res1',
      guestId: 'g3',
      guestName: 'Jean Malonga',
      roomId: 'r104',
      roomNumber: '104',
      checkIn: DateTime.now().add(const Duration(days: 1)),
      checkOut: DateTime.now().add(const Duration(days: 4)),
      status: ReservationStatus.confirmee,
      totalAmount: 270000,
    ),
    Reservation(
      id: 'res2',
      guestId: 'g4',
      guestName: 'Aïcha Bemba',
      roomId: 'r204',
      roomNumber: '204',
      checkIn: DateTime.now(),
      checkOut: DateTime.now().add(const Duration(days: 2)),
      status: ReservationStatus.enAttente,
      totalAmount: 180000,
    ),
  ];

  static final List<Employee> employees = [
    Employee(
      id: 'e1', firstName: 'Jean', lastName: 'Moukoko', phone: '+242 06 000 00 01',
      position: 'Réceptionniste', department: 'Réception', role: StaffRole.reception,
      hireDate: DateTime(2023, 3, 1), attendanceStatus: AttendanceStatus.present,
    ),
    Employee(
      id: 'e2', firstName: 'Grace', lastName: 'Nkounkou', phone: '+242 06 000 00 02',
      position: 'Chef de cuisine', department: 'Restaurant', role: StaffRole.restaurant,
      hireDate: DateTime(2022, 11, 15), attendanceStatus: AttendanceStatus.present,
    ),
    Employee(
      id: 'e3', firstName: 'Prince', lastName: 'Loemba', phone: '+242 06 000 00 03',
      position: 'Agent de maintenance', department: 'Maintenance', role: StaffRole.maintenance,
      hireDate: DateTime(2024, 1, 10), attendanceStatus: AttendanceStatus.enConge,
    ),
  ];

  static final List<HotelOrder> orders = [
    HotelOrder(
      id: 'o1', source: OrderSource.restaurant, roomNumber: '202', guestName: 'Aïcha Bemba',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      status: OrderStatus.enPreparation,
      lines: const [
        OrderLine(productName: 'Poulet Moambé', quantity: 2, unitPrice: 8000),
        OrderLine(productName: 'Jus de gingembre', quantity: 2, unitPrice: 2000),
      ],
    ),
    HotelOrder(
      id: 'o2', source: OrderSource.bar, roomNumber: '102', guestName: 'Jean Malonga',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: OrderStatus.nouvelle,
      lines: const [OrderLine(productName: 'Mojito', quantity: 1, unitPrice: 6000)],
    ),
  ];
}
