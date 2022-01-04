import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wean_app/blocs/cubit/yard_cubit.dart';
import 'package:wean_app/common/appTheme.dart';
import 'package:wean_app/widgets/textViews.dart';

Widget appBarBackWithCenterText(BuildContext context, String message) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0.0,
    centerTitle: true,
    title: Text(
      message,
      style: AppTheme.textTheme.headline2!
          .copyWith(fontSize: 18.0, color: Colors.white),
    ),
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: AppTheme.white,
      ),
    ),
  );
}

Widget appBarBackWithText(BuildContext context, String message) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0.0,
    centerTitle: false,
    automaticallyImplyLeading: true,
    title: Text(
      message,
      style: AppTheme.textTheme.headline2!
          .copyWith(fontSize: 18.0, color: Colors.white),
    ),
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: AppTheme.white,
      ),
    ),
  );
}

Widget appBarBackWithName(BuildContext context) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0.0,
    centerTitle: true,
    automaticallyImplyLeading: true,
    title: TextAppName(),
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: AppTheme.white,
      ),
    ),
  );
}

Widget appBarWithCenterText(BuildContext context, String message) {
  return AppBar(
    backgroundColor: AppTheme.primaryColor,
    elevation: 0.0,
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: TextTitle(
      text: message,
      textSize: 18,
    ),
  );
}

// Widget appBarWithName({required bool withActions}) {
//   return AppBar(
//     backgroundColor: AppTheme.primaryColor,
//     elevation: 0.0,
//     centerTitle: true,
//     automaticallyImplyLeading: false,
//     title: TextAppName(),
//     actions: withActions
//         ? [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(
//                 Icons.grid_on,
//               ),
//             ),
//           ]
//         : null,
//   );
// }

class AppBarWithName extends StatelessWidget {
  final bool withActions;
  const AppBarWithName({required this.withActions});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YardCubit, YardState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0.0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: TextAppName(),
          actions: withActions
              ? [
                  IconButton(
                    tooltip: state is YardList ? 'Grid mode' : 'List mode',
                    onPressed: () {
                      BlocProvider.of<YardCubit>(context).toggleYardMode();
                    },
                    icon: state is YardList
                        ? Icon(
                            Icons.grid_on,
                          )
                        : Icon(Icons.list),
                  ),
                ]
              : null,
        );
      },
    );
  }
}
