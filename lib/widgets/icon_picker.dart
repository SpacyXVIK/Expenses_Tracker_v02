import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final Function(IconData) onIconSelected;

  IconPicker({super.key, 
    required this.selectedIcon,
    required this.onIconSelected,
  });

  final List<IconData> icons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.movie,
    Icons.sports_esports,
    Icons.fitness_center,
    Icons.work,
    Icons.school,
    Icons.medical_services,
    Icons.home,
    Icons.shopping_bag,
    Icons.card_giftcard,
    Icons.attach_money,
    Icons.account_balance,
    Icons.flight_takeoff,
    Icons.hotel,
    Icons.sports,
    Icons.pets,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onIconSelected(icons[index]),
          child: Container(
            decoration: BoxDecoration(
              color: selectedIcon == icons[index]
                  ? Colors.deepPurple.withOpacity(0.2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icons[index],
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}