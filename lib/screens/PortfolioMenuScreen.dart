import 'package:flutter/material.dart';

import 'package:supply_chain_manager/widgets/NavigationButton.dart';
import 'package:supply_chain_manager/widgets/NavigationList.dart';

/// menu for navigating the the portfolio of persistent data
class PortfolioMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationList(title: 'My Portfolio', children: [
      NavigationButton.list('Owned Products', '/OwnedProducts'),
      NavigationButton.list('Managed Manufacturer-IDs', '/ManufacturerList'),
      NavigationButton.list('Trusted Manufacturer-IDs', '/TrustedManufacturers'),
    ]);
  }
}
