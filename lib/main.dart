import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketbase/pocketbase.dart';

void main() => runApp(const App());

final creation = ValueNotifier(_FallingSandState.emptyState(50));

final pb = PocketBase('https://falling-san.pockethost.io');

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: ConnectionWidget(
          child: Material(
            child: FallingSand(),
          ),
        ),
      ),
    );
  }
}

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

class FallingSand extends StatefulWidget {
  const FallingSand({super.key});

  @override
  State<FallingSand> createState() => _FallingSandState();
}

class _FallingSandState extends State<FallingSand>
    with TickerProviderStateMixin {
  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(tick)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void tick(Duration duration) {
    for (var col = 0; col < cellCount; col++) {
      for (var row = cellCount - 1; row >= 0; row--) {
        var color = state[col][row];
        if (color != null) {
          var canMoveDown = row + 1 < cellCount && state[col][row + 1] == null;
          if (canMoveDown) {
            setState(() {
              state[col][row + 1] = color;
              state[col][row] = null;
            });
          }
        }
      }
    }
  }

  var cellCount = 50;

  List<List<Color?>> get state => creation.value;
  set state(List<List<Color?>> val) => creation.value = val;

  static List<List<Color?>> emptyState(int size) =>
      List.generate(size, (i) => List.generate(size, (j) => null));

  final size = const Size.square(1000);

  late var cellSize = Size(
    size.width / cellCount,
    size.height / cellCount,
  );

  Color? color = Colors.black;

  void positionToCellUpdate(Offset offset) {
    var x = max(0, offset.dx) ~/ cellSize.width;
    var y = max(0, offset.dy) ~/ cellSize.height;

    x = min(x, cellCount - 1);
    y = min(y, cellCount - 1);

    if (state[x][y] != null) return;

    setState(() => state[x][y] = color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < Colors.primaries.length; i++)
                IconButton(
                  icon: const Icon(Icons.square),
                  tooltip: i < 9 ? '${i + 1}' : null,
                  color: Colors.primaries[i],
                  onPressed: () => setState(() => color = Colors.primaries[i]),
                ),
              IconButton(
                icon: const Icon(Icons.square),
                color: Colors.black,
                onPressed: () => setState(() => color = Colors.black),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Some Pixels',
                      icon: const Icon(Icons.density_large),
                      onPressed: () => setState(() {
                        cellCount = 50;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.density_medium),
                      tooltip: 'More Pixels',
                      onPressed: () => setState(() {
                        cellCount = 250;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                    IconButton(
                      tooltip: 'Most Pixels',
                      icon: const Icon(Icons.density_small),
                      onPressed: () => setState(() {
                        cellCount = 500;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => state = emptyState(cellCount)),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all()),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(size),
              child: Listener(
                child: CustomPaint(
                  size: size,
                  painter: FallingSandPainter(state),
                ),
                onPointerHover: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerMove: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerDown: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerUp: (event) =>
                    positionToCellUpdate(event.localPosition),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Size buildCellSize() {
    return Size(
      size.width / cellCount,
      size.height / cellCount,
    );
  }
}

class FallingSandPainter extends CustomPainter {
  FallingSandPainter(this.state);
  final List<List<Color?>> state;
  var paintBrush = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    var width = state.length;
    var height = state[0].length;
    var divisionX = size.width / width;
    var divisionY = size.height / height;

    // add 1 to account for ghost lines
    final cellSize = Size(divisionX + 1, divisionY + 1);

    for (var col = 0; col < width; col++) {
      for (var row = 0; row < height; row++) {
        var color = state[col][row];
        if (color != null) {
          var rect = Offset(col * divisionX, row * divisionY) & cellSize;
          canvas.drawRect(rect, paintBrush..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FallingSandPainter oldDelegate) {
    return true;
  }
}

class CreationModel {
  final List<List<Color?>> data;

  const CreationModel({required this.data});

  // List<List<int?>> toJson() => data.map((row) => row.map((cell) => cell?.value).toList()).toList();

  factory CreationModel.fromJson(Map<String, dynamic> source) {
    if (source case {'data': List data}) {
      return CreationModel(
          data: data
              .cast<List<int>>()
              .map((row) => row.map((cell) => Color(cell)).toList())
              .toList());
    }

    throw UnsupportedError(
      'The format of the response is not supported.\n$source',
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final username = TextEditingController();
  final password = TextEditingController();
  var showPassword = false;
  String? error;

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
                controller: username,
                decoration: const InputDecoration(hintText: 'username'),
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.newUsername
                ],
              ),
              TextField(
                controller: password,
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
                    onPressed: () async {
                      RecordAuth? recordAuth;
                      try {
                        recordAuth =
                            await pb.collection('users').authWithPassword(
                                  username.text,
                                  password.text,
                                );
                      } on ClientException catch (e) {
                        setState(() => error = '${e.response}');
                      }

                      if (recordAuth != null && context.mounted) {
                        return Navigator.of(context).pop();
                      } else {
                        password.clear();
                      }
                    },
                    child: const Text('login'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      RecordModel? model;
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
                      }
                      if (model != null && model.id.isNotEmpty) {
                        print(model.data);
                      }
                    },
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
