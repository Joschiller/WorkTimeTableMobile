import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:work_time_table_mobile/utils.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key, required this.headers});

  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) => Row(
        children: headers.entries
            .map(
              (header) => Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Wrap(
                          children: [
                            Text(
                              header.key,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      if (header.value.isNotBlank)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(header.key),
                                content: SingleChildScrollView(
                                  child: Wrap(
                                    children: [
                                      Text(header.value),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: context.pop,
                                    child: const Text('Ok'),
                                  )
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
}
