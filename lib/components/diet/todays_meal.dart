import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';

class TodayMealsCard extends StatefulWidget {
  final bool isDarkMode;

  const TodayMealsCard({super.key, this.isDarkMode = false});

  @override
  State<TodayMealsCard> createState() => _TodayMealsCardState();
}

class _TodayMealsCardState extends State<TodayMealsCard> {
  final Map<String, List<Map<String, String>>> meals = {
    'Breakfast': [
      {
        'title': 'Oatmeal with Fruits',
        'quantity': '1 Bowl',
        'calories': '350 kcal',
      },
      {'title': 'Boiled Eggs', 'quantity': '2 pieces', 'calories': '155 kcal'},
    ],
    'Lunch': [
      {
        'title': 'Grilled Chicken & Rice',
        'quantity': '1 Plate',
        'calories': '620 kcal',
      },
    ],
    'Dinner': [],
  };

  void addMeal(String mealType) {
    setState(() {
      meals[mealType]?.add({
        'title': 'New Meal',
        'quantity': '1 serving',
        'calories': '200 kcal',
      });
    });
  }

  void deleteMeal(String mealType, int index) {
    setState(() {
      meals[mealType]?.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final bool dark = widget.isDarkMode;

    final containerBg = dark ? const Color(0xFF161616) : Colors.white;
    final containerBorder = dark ? Colors.white12 : Colors.grey.shade300;
    final containerShadow = dark
        ? Colors.black.withOpacity(0.6)
        : Colors.black.withOpacity(0.04);
    final sectionBg = dark ? const Color(0xFF111111) : Colors.grey.shade50;
    final sectionTextColor = dark ? Colors.white70 : Colors.black87;
    final headerTextColor = dark ? Colors.white : Colors.black87;
    final mutedTextColor = dark ? Colors.white54 : Colors.black45;
    final dividerColor = dark ? Colors.white12 : Colors.black12;
    final iconBg = dark
        ? Colors.white.withOpacity(0.03)
        : Colors.black.withOpacity(0.05);
    final iconColor = Colors.blue; // keep accent

    return Container(
      margin: EdgeInsets.only(top: SizeConfig.h(0)),
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(22)),
        border: Border.all(color: containerBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: containerShadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: meals.entries.map((entry) {
          return buildMealSection(
            entry.key,
            entry.value,
            dark,
            sectionBg,
            headerTextColor,
            sectionTextColor,
            mutedTextColor,
            dividerColor,
            iconBg,
            iconColor,
          );
        }).toList(),
      ),
    );
  }

  Widget buildMealSection(
    String mealType,
    List<Map<String, String>> mealList,
    bool dark,
    Color sectionBg,
    Color headerTextColor,
    Color sectionTextColor,
    Color mutedTextColor,
    Color dividerColor,
    Color iconBg,
    Color iconColor,
  ) {
    IconData mealIcon;
    switch (mealType) {
      case 'Breakfast':
        mealIcon = Icons.wb_sunny_outlined;
        break;
      case 'Lunch':
        mealIcon = Icons.fastfood_outlined;
        break;
      case 'Dinner':
        mealIcon = Icons.nightlight_round_outlined;
        break;
      default:
        mealIcon = Icons.restaurant_menu_rounded;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeConfig.w(8)),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mealIcon,
                      color: iconColor,
                      size: SizeConfig.w(20),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Text(
                    mealType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: headerTextColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => addMeal(mealType),
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.add_circle_outline_outlined,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(6)),

          if (mealList.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.h(4)),
              child: Text(
                'No meals added yet',
                style: TextStyle(color: mutedTextColor, fontSize: 14),
              ),
            )
          else
            Column(
              children: mealList.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: SizeConfig.h(4)),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(10),
                    vertical: SizeConfig.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: sectionBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['title']!,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: sectionTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: SizeConfig.h(2)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  meal['quantity']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: mutedTextColor,
                                  ),
                                ),
                                SizedBox(width: SizeConfig.w(10)),
                                Text(
                                  meal['calories']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: mutedTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () => deleteMeal(mealType, index),
                        icon: Icon(
                          Icons.close_rounded,
                          color: mutedTextColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          if (mealType != 'Dinner')
            Padding(
              padding: EdgeInsets.only(top: SizeConfig.h(10)),
              child: Divider(
                color: dividerColor,
                thickness: 0.8,
                endIndent: SizeConfig.w(6),
                indent: SizeConfig.w(6),
              ),
            ),
        ],
      ),
    );
  }
}
