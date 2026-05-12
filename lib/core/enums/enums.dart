/// All domain-specific enums for AgriConnect
library;

enum UserRole { FARMER, BUYER, DELIVERER, ADMIN }

enum ActivityType {
  VEGETABLES_FRUITS,
  DATES,
  LIVESTOCK,
  POULTRY;

  String get label {
    switch (this) {
      case VEGETABLES_FRUITS:
        return 'Vegetables & Fruits';
      case DATES:
        return 'Dates';
      case LIVESTOCK:
        return 'Livestock';
      case POULTRY:
        return 'Poultry';
    }
  }
}

enum VehicleType {
  FOURGON,
  FOURGON_REFRIGERE,
  HARBIN,
  CAMION,
  CAMION_REFRIGERE,
  HILUX;

  String get label {
    switch (this) {
      case FOURGON:
        return 'Standard Van';
      case FOURGON_REFRIGERE:
        return 'Refrigerated Van';
      case HARBIN:
        return 'Harbin Truck';
      case CAMION:
        return 'Standard Truck';
      case CAMION_REFRIGERE:
        return 'Refrigerated Truck';
      case HILUX:
        return 'Toyota Hilux';
    }
  }
}

enum OrderStatus {
  PENDING,
  REJECTED,
  AWAITING_BUYER_PICKUP,
  AWAITING_DELIVERER_ASSIGN,
  AWAITING_DELIVERER_PICKUP,
  IN_TRANSIT,
  COMPLETED;

  String get label {
    switch (this) {
      case PENDING:
        return 'Pending';
      case REJECTED:
        return 'Rejected';
      case AWAITING_BUYER_PICKUP:
        return 'Awaiting Pickup';
      case AWAITING_DELIVERER_ASSIGN:
        return 'Finding Deliverer';
      case AWAITING_DELIVERER_PICKUP:
        return 'Deliverer Assigned';
      case IN_TRANSIT:
        return 'In Transit';
      case COMPLETED:
        return 'Completed';
    }
  }

  /// Returns index in the visual timeline for delivery flow
  int get timelineStep {
    switch (this) {
      case PENDING:
        return 0;
      case AWAITING_DELIVERER_ASSIGN:
        return 1;
      case AWAITING_DELIVERER_PICKUP:
        return 2;
      case IN_TRANSIT:
        return 3;
      case COMPLETED:
        return 4;
      default:
        return -1;
    }
  }
}

enum DeliveryOption {
  WITH_DELIVERY,
  WITHOUT_DELIVERY;

  String get label {
    switch (this) {
      case WITH_DELIVERY:
        return 'With Delivery';
      case WITHOUT_DELIVERY:
        return 'Pick up at Farm';
    }
  }
}

enum ProductSortBy {
  price_asc,
  price_desc,
  date_desc,
  rating_desc;

  String get label {
    switch (this) {
      case price_asc:
        return 'Price: Low to High';
      case price_desc:
        return 'Price: High to Low';
      case date_desc:
        return 'Newest First';
      case rating_desc:
        return 'Highest Rated';
    }
  }
}
