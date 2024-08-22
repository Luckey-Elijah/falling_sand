import 'dart:math';

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
                    const BrowseCreationsButton(),
                    const SizedBox(width: 8),
                    if (isNotAuth(data)) _buildLoginButton(),
                    if (isAuth(data)) ...[
                      _buildSubmitCreationButton(data),
                      const SizedBox(width: 8),
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

  Widget _buildSubmitCreationButton(AuthStoreEvent? data) {
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

  Widget _buildLoginButton() {
    return TextButton(
      child: const Text('Login'),
      onPressed: () async => showAdaptiveDialog<void>(
        context: context,
        builder: (context) {
          return const LoginWidget();
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        backgroundColor: Colors.red.shade100,
      ),
      child: const Text('Logout'),
      onPressed: () => pb.authStore.clear(),
    );
  }
}

class BrowseCreationsButton extends StatelessWidget {
  const BrowseCreationsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: const Text('Browse Creations'),
      onPressed: () => showAdaptiveDialog<void>(
        context: context,
        builder: (context) => const BrowseWidget(),
      ),
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
    final resultList = await pb.collection('creations').getList(
          expand: 'user',
          sort: '-created',
        );
    final data = resultList.items.map(
      (item) => {...item.data, ...item.expand},
    );
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
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final hasDataReady =
              !loading && snapshot.hasData && snapshot.data!.isNotEmpty;

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
              if (hasDataReady)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth ~/ 480;
                      return GridView.builder(
                        itemCount: snapshot.data?.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: max(crossAxisCount, 1),
                        ),
                        itemBuilder: (context, index) {
                          final state = snapshot.data![index].data;
                          final name = snapshot.data![index].user;
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (name != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: NameTag(name: name),
                                  ),
                                if (name == null)
                                  const NameTag(name: 'Unknown submission'),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: InkWell(
                                          onTap: Navigator.of(context).pop,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: CreationView(
                                              state: state,
                                              size: Size.infinite,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: CreationView(state: state),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              if (loading) const CircularProgressIndicator.adaptive(),
              if (!hasDataReady && !loading) const Text('Nothing to show'),
            ],
          );
        },
      ),
    );
  }
}

class NameTag extends StatelessWidget {
  const NameTag({
    required this.name,
    super.key,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: Text(name),
        ),
      ),
    );
  }
}

class CreationView extends StatelessWidget {
  const CreationView({
    required this.state,
    this.size = Size.zero,
    super.key,
  });

  final List<List<Color?>> state;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: size,
        painter: FallingSandPainter(state, state.length),
      ),
    );
  }
}
