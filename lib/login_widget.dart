import 'package:falling_sand/main.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final username = TextEditingController();
  final password = TextEditingController();
  var showPassword = false;
  var loading = false;
  String? error;

  Future<void> login() async {
    RecordAuth? recordAuth;
    try {
      setState(() => loading = true);
      recordAuth = await pb.collection('users').authWithPassword(
            username.text,
            password.text,
          );
    } on ClientException catch (e) {
      setState(() => error = '${e.response}');
    } finally {
      setState(() => loading = false);
    }

    var context = this.context;

    if (recordAuth != null && context.mounted) {
      return Navigator.of(context).pop();
    } else {
      password.clear();
    }
  }

  Future<void> createAccount() async {
    RecordModel? model;
    setState(() => loading = true);
    try {
      model = await pb.collection('users').create(
        body: {
          'username': username.text,
          'password': password.text,
          'passwordConfirm': password.text,
          'emailVisibility': false,
        },
      );
    } on ClientException catch (e) {
      setState(() => error = '${e.response}');
    } finally {
      setState(() => loading = false);
    }

    if (model != null && model.id.isNotEmpty) await login();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Spacer(),
                  const CloseButton(),
                ],
              ),
              TextField(
                enabled: !loading,
                controller: username,
                decoration: const InputDecoration(hintText: 'username'),
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.newUsername
                ],
              ),
              TextField(
                enabled: !loading,
                controller: password,
                onSubmitted: (value) {},
                decoration: InputDecoration(
                  hintText: 'password',
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => showPassword = !showPassword,
                    ),
                    icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                autofillHints: const [
                  AutofillHints.password,
                  AutofillHints.newPassword
                ],
                obscureText: !showPassword,
              ),
              if (error != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CloseButton(onPressed: () => setState(() => error = null)),
                    Flexible(child: Text('$error')),
                  ],
                ),
              Row(
                children: [
                  TextButton(
                    onPressed: loading ? null : login,
                    child: const Text('login'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: loading ? null : createAccount,
                    child: const Text('create an account'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
