import 'package:falling_sand/creation_model.dart';
import 'package:falling_sand/falling_sand_painter.dart';
import 'package:falling_sand/login_widget.dart';
import 'package:falling_sand/main.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ConnectionWidget extends StatefulWidget {
  const ConnectionWidget({required this.child, super.key});
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
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isNotAuth(data)) _buildLoginButton(),
                    if (isAuth(data)) ...[
                      OutlinedButton(
                        child: const Text('Browse Creations'),
                        onPressed: () async {
                          await showAdaptiveDialog<void>(
                            context: context,
                            builder: (context) {
                              return const BrowseWidget();
                            },
                          );
                        },
                      ),
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

  Future<void> submitCreation(AuthStoreEvent? data) async {
    RecordModel? record;

    try {
      record = await pb.collection('creations').create(
        body: {
          'user': (data?.model as RecordModel).id,
          'data': creation.value
              .map((row) => row.map((cell) => cell?.value).toList())
              .toList(),
        },
      );
    } on ClientException catch (e) {
      final ctx = context;
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('${e.response}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (record != null) {
      final ctx = context;
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Creation uploaded!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  OutlinedButton _buildSubmitCreationButton(AuthStoreEvent? data) {
    return OutlinedButton(
      onPressed: () => submitCreation(data),
      child: const Text('Submit Creation'),
    );
  }

  bool isAuth(AuthStoreEvent? data) {
    if (data?.model == null) return false;
    if (data?.token.isEmpty ?? false) return false;
    if (data == null) return false;
    return true;
  }

  bool isNotAuth(AuthStoreEvent? data) {
    return data == null || data.token.isEmpty == true || data.model == null;
  }

  TextButton _buildLoginButton() {
    return TextButton(
      child: const Text('Login'),
      onPressed: () async {
        await showAdaptiveDialog<void>(
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

class BrowseWidget extends StatefulWidget {
  const BrowseWidget({super.key});

  @override
  State<BrowseWidget> createState() => _BrowseWidgetState();
}

class _BrowseWidgetState extends State<BrowseWidget> {
  Future<List<CreationModel>>? creationsFuture;

  Future<List<CreationModel>> getCreations() async {
    FutureBuilder.debugRethrowError = true;
    final resultList = await pb.collection('creations').getList();
    final data = resultList.items.map((item) => item.data).toList();
    final creations = data.map(CreationModel.fromJson).toList();

    return creations;
  }

  @override
  void initState() {
    creationsFuture = getCreations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: FutureBuilder(
        future: creationsFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {
                      creationsFuture = getCreations();
                    }),
                  ),
                  const Text('Browse Creations'),
                  const CloseButton(),
                ],
              ),
              if (snapshot.hasData)
                Expanded(
                  child: GridView.builder(
                    itemCount: snapshot.data?.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(36),
                        child: DecoratedBox(
                          decoration: BoxDecoration(border: Border.all()),
                          child: CustomPaint(
                            painter:
                                FallingSandPainter(snapshot.data![index].data),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
