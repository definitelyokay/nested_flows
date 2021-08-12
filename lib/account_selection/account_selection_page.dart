import 'package:flutter/material.dart';
import 'package:nested_flows/l10n/l10n.dart';
import 'package:nested_flows/models/models.dart';

class AccountSelectionPage extends StatelessWidget {
  const AccountSelectionPage({Key? key, required this.accounts})
      : super(key: key);

  final List<Account> accounts;

  static Page<void> page({required List<Account> accounts}) {
    return MaterialPage<void>(
      key: UniqueKey(),
      child: AccountSelectionPage(accounts: accounts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AccountSelectionPageView(accounts: accounts);
  }
}

class AccountSelectionPageView extends StatelessWidget {
  const AccountSelectionPageView({Key? key, required this.accounts})
      : super(key: key);

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WillPopScope(
      onWillPop: () async {
        // Currently causes a rebuild which cancels animations.
        //
        // Possibly need support from flow_builder possibly to update the
        // flow state without updating the pages since it's about to occur
        // anyways?
        //
        // flow.update() animates incorrectly because it thinks going back to
        // the  previous screen is actually a push since the pages have
        // different keys?
        //
        // flow.complete() DOES animate correctly because you are popping the
        // entire navigator off.
        //
        // The only way to swap out the back behavior would be to return
        // entirely different stacks based on loading state.
        //
        //
        // import 'package:flow_builder/flow_builder.dart';
        // import 'package:nested_flows/bank_link/bank_link.dart';
        // context.flow<BankLinkFlowState>().update(
        //       (flowState) => BankLinkFlowState(
        //         banks: flowState.banks,
        //         accounts: flowState.accounts,
        //         // Clear out other properties
        //       ),
        //     );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.accountSelectionAppBarTitle),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.account_balance, size: 36),
              title: Text(accounts[index].name),
              trailing: const Icon(Icons.chevron_right, size: 36),
            );
          },
          itemCount: accounts.length,
        ),
      ),
    );
  }
}
