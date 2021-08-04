import 'dart:developer';

import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:nested_flows/account_selection/account_selection.dart';
import 'package:nested_flows/account_selection/account_selection_page.dart';
import 'package:nested_flows/bank_link/bank_link_flow_state.dart';
import 'package:nested_flows/bank_selection/bank_selection.dart';
import 'package:nested_flows/loading/loading.dart';
import 'package:nested_flows/models/models.dart';

class BankLinkFlow extends StatelessWidget {
  const BankLinkFlow({Key? key}) : super(key: key);

  static Route<BankLinkFlowState> route() {
    return MaterialPageRoute(
      builder: (_) => const BankLinkFlow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const FlowBuilder<BankLinkFlowState>(
      state: BankLinkFlowState(),
      onGeneratePages: onGeneratePages,
      transitionDelegate: MyTransitionDelegate<dynamic>(),
    );
  }

  static List<Page> onGeneratePages(BankLinkFlowState state, List<Page> pages) {
    log('state: $state');
    return [
      LoadingScreen.page<List<Bank>>(
        load: () async {
          return Future.delayed(
            const Duration(seconds: 2),
            () async => const [
              Bank(name: 'My First Bank'),
              Bank(name: 'Big Conglomerate of Banks'),
              Bank(name: 'Bankiest Bank'),
              Bank(name: 'Capitalist Corp.'),
            ],
          );
        },
        onSuccess: (context, data) {
          context
              .flow<BankLinkFlowState>()
              .update((flowState) => BankLinkFlowState(banks: data));
        },
        onError: (context, error) {
          context.flow<BankLinkFlowState>().complete();
        },
      ),
      if (state.banks != null)
        BankSelectionPage.page(
          banks: state.banks ?? [],
        ),
      if (state.selectedBank != null && state.accounts == null)
        LoadingScreen.page<List<Account>>(
          load: () async {
            return Future.delayed(
              const Duration(seconds: 2),
              () async => const [
                Account(name: 'Account #1234567893'),
                Account(name: 'Account #0234513811'),
                Account(name: 'Account #5183138501'),
              ],
            );
          },
          onSuccess: (context, data) {
            context.flow<BankLinkFlowState>().update(
                  (flowState) => BankLinkFlowState(
                    banks: flowState.banks,
                    accounts: data,
                    selectedBank: flowState.selectedBank,
                  ),
                );
          },
          onError: (context, error) {
            context.flow<BankLinkFlowState>().complete();
          },
        )
      else if (state.selectedBank != null && state.accounts != null)
        AccountSelectionPage.page(
          accounts: state.accounts ?? [],
        ),
    ];
  }
}

class MyTransitionDelegate<T> extends DefaultTransitionDelegate<T> {
  const MyTransitionDelegate() : super();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    log('new page route history: $newPageRouteHistory');
    log('location to exiting page route: $locationToExitingPageRoute');
    log('page route to pageless routes $pageRouteToPagelessRoutes');
    log('next transition');
    log('');
    final results = <RouteTransitionRecord>[];
    // This method will handle the exiting route and its corresponding pageless
    // route at this location. It will also recursively check if there is any
    // other exiting routes above it and handle them accordingly.
    void handleExitingRoute(RouteTransitionRecord? location, bool isLast) {
      final exitingPageRoute = locationToExitingPageRoute[location];
      if (exitingPageRoute == null) {
        return;
      }
      if (exitingPageRoute.isWaitingForExitingDecision) {
        final hasPagelessRoute =
            pageRouteToPagelessRoutes.containsKey(exitingPageRoute);
        final isLastExitingPageRoute =
            isLast && !locationToExitingPageRoute.containsKey(exitingPageRoute);
        if (isLastExitingPageRoute && !hasPagelessRoute) {
          exitingPageRoute.markForPop(exitingPageRoute.route.currentResult);
        } else {
          exitingPageRoute
              .markForComplete(exitingPageRoute.route.currentResult);
        }
        if (hasPagelessRoute) {
          final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute]!;
          for (final pagelessRoute in pagelessRoutes) {
            // It is possible that a pageless route that belongs to an exiting
            // page-based route does not require exiting decision. This can
            // happen if the page list is updated right after a Navigator.pop.
            if (pagelessRoute.isWaitingForExitingDecision) {
              if (isLastExitingPageRoute &&
                  pagelessRoute == pagelessRoutes.last) {
                pagelessRoute.markForPop(pagelessRoute.route.currentResult);
              } else {
                pagelessRoute
                    .markForComplete(pagelessRoute.route.currentResult);
              }
            }
          }
        }
      }
      results.add(exitingPageRoute);

      // It is possible there is another exiting route
      // above this exitingPageRoute.
      handleExitingRoute(exitingPageRoute, isLast);
    }

    // Handles exiting route in the beginning of list.
    handleExitingRoute(null, newPageRouteHistory.isEmpty);

    for (final pageRoute in newPageRouteHistory) {
      final isLastIteration = newPageRouteHistory.last == pageRoute;
      if (pageRoute.isWaitingForEnteringDecision) {
        if (!locationToExitingPageRoute.containsKey(pageRoute) &&
            isLastIteration) {
          pageRoute.markForPush();
        } else {
          // pageRoute.markForAdd();
          pageRoute.markForPush();
        }
      }
      results.add(pageRoute);
      handleExitingRoute(pageRoute, isLastIteration);
    }
    return results;
  }
}
