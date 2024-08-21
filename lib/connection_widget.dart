import 'package:falling_sand/login_widget.dart';
import 'package:falling_sand/main.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ConnectionWidget extends StatefulWidget {
  const ConnectionWidget({super.key, required this.child});
  final Widget child;

  @override
  State<ConnectionWidget> createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> {
  final stream = pb.authStore.onChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: widget.child),
        StreamBuilder<AuthStoreEvent?>(
          stream: stream,
          builder: (context, snapshot) {
            final data = snapshot.data;

            return Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isNotAuth(data)) _buildLoginButton(),
                    if (isAuth(data)) ...[
                      _buildSubmitCreationButton(data),
                      _buildLogoutButton(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  OutlinedButton _buildSubmitCreationButton(AuthStoreEvent? data) {
    return OutlinedButton(
      onPressed: () async {
        final body = <String, dynamic>{
          'user': data?.model.id,
          'data': creation.value
              .map((row) => row.map((cell) => cell?.value).toList())
              .toList(),
        };
        RecordModel? record;

        try {
          record = await pb.collection('creations').create(body: body);
        } on ClientException catch (e) {
          var ctx = context;
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('${e.response}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (record != null) {
          var ctx = context;
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Creation uploaded!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Text('Submit Creation'),
    );
  }

  bool isAuth(AuthStoreEvent? data) {
    if (data?.model == null) return false;
    if (data?.token.isEmpty == true) return false;
    if (data == null) return false;
    return true;
  }

  bool isNotAuth(AuthStoreEvent? data) {
    return data == null || data.token.isEmpty == true || data.model == null;
  }

  TextButton _buildLoginButton() {
    return TextButton(
      child: const Text('Login'),
      onPressed: () {
        showAdaptiveDialog(
          context: context,
          builder: (context) {
            return const LoginWidget();
          },
        );
      },
    );
  }

  TextButton _buildLogoutButton() {
    return TextButton(
      child: const Text('Logout'),
      onPressed: () => pb.authStore.clear(),
    );
  }
}
