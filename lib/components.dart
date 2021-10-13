import 'imports.dart';

class DashboardTile extends StatelessWidget {
  final num value;
  final String unit, description;
  final bool? isSubscript;
  final Widget page;

  DashboardTile({
    this.value = 0.0,
    this.unit = "",
    this.description = "",
    this.isSubscript,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(k_size),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(k_radius),
        border: Border.all(
          color: k_secondaryColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(k_size * 1.5),
          child: Row(
            children: [
              Container(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: FittedBox(
                        child: Row(
                          children: [
                            Text(
                              "$value",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: k_secondaryColor,
                              ),
                            ),
                            Text(
                              unit,
                              textScaleFactor: isSubscript != null ? 0.6 : 1.0,
                              style: TextStyle(
                                height: isSubscript != null ? (isSubscript! ? 1.6 : 0.2) : null,
                                fontWeight: isSubscript == null ? FontWeight.w300 : FontWeight.w200,
                                color: k_secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: k_size),
                    Text(
                      description,
                      style: TextStyle(
                        color: k_greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
