import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_dialog.dart';

enum TicketStatus { open, inProgress, resolved, closed }

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String message;
  TicketStatus status;
  final DateTime createdAt;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.messages,
  });
}

class TicketMessage {
  final String text;
  final bool isAdmin;
  final DateTime sentAt;
  const TicketMessage({
    required this.text,
    required this.isAdmin,
    required this.sentAt,
  });
}

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  TicketStatus? _filterStatus;
  SupportTicket? _selectedTicket;

  final List<SupportTicket> _tickets = [
    SupportTicket(
      id: 'TK001',
      userId: 'u1',
      userName: 'Ahmad Al-Hassan',
      subject: 'Driver did not arrive at pickup location',
      message: 'I waited 20 minutes and the driver never came.',
      status: TicketStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      messages: [
        TicketMessage(
            text: 'I waited 20 minutes and the driver never came.',
            isAdmin: false,
            sentAt: DateTime.now().subtract(const Duration(hours: 2))),
      ],
    ),
    SupportTicket(
      id: 'TK002',
      userId: 'u2',
      userName: 'Sara Yousef',
      subject: 'Overcharged for my ride',
      message: 'The final price was much higher than the bid.',
      status: TicketStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: [
        TicketMessage(
            text: 'The final price was much higher than the bid.',
            isAdmin: false,
            sentAt: DateTime.now().subtract(const Duration(days: 1))),
        TicketMessage(
            text: 'Thank you for reaching out. We are investigating.',
            isAdmin: true,
            sentAt: DateTime.now().subtract(const Duration(hours: 20))),
      ],
    ),
    SupportTicket(
      id: 'TK003',
      userId: 'u3',
      userName: 'Khalid Nasser',
      subject: 'App crashes when booking',
      message: 'Every time I try to book a ride the app closes.',
      status: TicketStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      messages: [
        TicketMessage(
            text: 'Every time I try to book a ride the app closes.',
            isAdmin: false,
            sentAt: DateTime.now().subtract(const Duration(days: 3))),
        TicketMessage(
            text: 'Issue resolved in app version 1.2.1. Please update.',
            isAdmin: true,
            sentAt: DateTime.now().subtract(const Duration(days: 2))),
      ],
    ),
  ];

  List<SupportTicket> get _filteredTickets {
    if (_filterStatus == null) return _tickets;
    return _tickets.where((t) => t.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Support Tickets',
      child: Row(
        children: [
          // Ticket list
          SizedBox(
            width: 380,
            child: Column(
              children: [
                // Filter chips
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: DozColors.surfaceLight,
                    border:
                        Border(bottom: BorderSide(color: DozColors.borderLight)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusFilterChip(
                            label: 'All', isSelected: _filterStatus == null,
                            onTap: () =>
                                setState(() => _filterStatus = null)),
                        const SizedBox(width: 6),
                        ...[
                          TicketStatus.open,
                          TicketStatus.inProgress,
                          TicketStatus.resolved,
                          TicketStatus.closed,
                        ].map((s) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _StatusFilterChip(
                                label: _statusLabel(s),
                                isSelected: _filterStatus == s,
                                color: _statusColor(s),
                                onTap: () =>
                                    setState(() => _filterStatus = s),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

                // Ticket list
                Expanded(
                  child: _filteredTickets.isEmpty
                      ? const Center(
                          child: Text(
                            'No tickets found',
                            style: TextStyle(color: DozColors.textMutedLight),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTickets.length,
                          itemBuilder: (ctx, i) {
                            final ticket = _filteredTickets[i];
                            return _TicketListItem(
                              ticket: ticket,
                              isSelected: _selectedTicket?.id == ticket.id,
                              onTap: () =>
                                  setState(() => _selectedTicket = ticket),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            color: DozColors.borderLight,
          ),

          // Ticket detail
          Expanded(
            child: _selectedTicket == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent,
                            size: 48, color: DozColors.textDisabledLight),
                        SizedBox(height: 12),
                        Text(
                          'Select a ticket to view details',
                          style: TextStyle(color: DozColors.textMutedLight),
                        ),
                      ],
                    ),
                  )
                : _TicketDetail(
                    ticket: _selectedTicket!,
                    onStatusChange: (status) {
                      setState(() => _selectedTicket!.status = status);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  Color _statusColor(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return DozColors.error;
      case TicketStatus.inProgress:
        return DozColors.warning;
      case TicketStatus.resolved:
        return DozColors.success;
      case TicketStatus.closed:
        return DozColors.textMutedLight;
    }
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? DozColors.primaryGreen).withOpacity(0.1)
              : DozColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? DozColors.primaryGreen)
                : DozColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (color ?? DozColors.primaryGreen)
                : DozColors.textMutedLight,
          ),
        ),
      ),
    );
  }
}

class _TicketListItem extends StatelessWidget {
  final SupportTicket ticket;
  final bool isSelected;
  final VoidCallback onTap;

  const _TicketListItem({
    required this.ticket,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? DozColors.primaryGreenSurface : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: DozColors.borderLightSubtle),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${ticket.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'RobotoMono',
                    color: DozColors.textMutedLight,
                  ),
                ),
                const Spacer(),
                _TicketStatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ticket.subject,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? DozColors.primaryGreen
                    : DozColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 12, color: DozColors.textMutedLight),
                const SizedBox(width: 4),
                Text(
                  ticket.userName,
                  style: const TextStyle(
                      fontSize: 11, color: DozColors.textMutedLight),
                ),
                const Spacer(),
                Text(
                  DozFormatters.timeAgo(ticket.createdAt, lang: 'en'),
                  style: const TextStyle(
                      fontSize: 11, color: DozColors.textMutedLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _TicketStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color, bg;
    String label;
    switch (status) {
      case TicketStatus.open:
        color = DozColors.error;
        bg = DozColors.errorLight;
        label = 'Open';
        break;
      case TicketStatus.inProgress:
        color = DozColors.warning;
        bg = DozColors.warningLight;
        label = 'In Progress';
        break;
      case TicketStatus.resolved:
        color = DozColors.success;
        bg = DozColors.successLight;
        label = 'Resolved';
        break;
      case TicketStatus.closed:
        color = DozColors.textMutedLight;
        bg = DozColors.borderLightSubtle;
        label = 'Closed';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TicketDetail extends StatefulWidget {
  final SupportTicket ticket;
  final void Function(TicketStatus) onStatusChange;

  const _TicketDetail({
    required this.ticket,
    required this.onStatusChange,
  });

  @override
  State<_TicketDetail> createState() => _TicketDetailState();
}

class _TicketDetailState extends State<_TicketDetail> {
  final _replyCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: DozColors.surfaceLight,
            border: Border(bottom: BorderSide(color: DozColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: DozColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From: ${ticket.userName} • ${DozFormatters.dateShort(ticket.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DozColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status selector
              DropdownButton<TicketStatus>(
                value: ticket.status,
                underline: const SizedBox(),
                onChanged: (s) {
                  if (s != null) widget.onStatusChange(s);
                },
                items: TicketStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(_statusLabel(s),
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(20),
            itemCount: ticket.messages.length,
            itemBuilder: (ctx, i) {
              final msg = ticket.messages[i];
              return _MessageBubble(message: msg);
            },
          ),
        ),

        // Reply box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: DozColors.surfaceLight,
            border: Border(top: BorderSide(color: DozColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyCtrl,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: DozColors.textDisabledLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: DozColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: DozColors.borderLight),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_replyCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      ticket.messages.add(TicketMessage(
                        text: _replyCtrl.text.trim(),
                        isAdmin: true,
                        sentAt: DateTime.now(),
                      ));
                      _replyCtrl.clear();
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollCtrl.hasClients) {
                        _scrollCtrl.animateTo(
                          _scrollCtrl.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 48),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.resolved: return 'Resolved';
      case TicketStatus.closed: return 'Closed';
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final TicketMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: message.isAdmin
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isAdmin
                    ? DozColors.primaryGreenSurface
                    : DozColors.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: message.isAdmin
                      ? const Radius.circular(12)
                      : const Radius.circular(2),
                  bottomRight: message.isAdmin
                      ? const Radius.circular(2)
                      : const Radius.circular(12),
                ),
                border: Border.all(
                  color: message.isAdmin
                      ? DozColors.primaryGreen.withOpacity(0.2)
                      : DozColors.borderLight,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  color: message.isAdmin
                      ? DozColors.primaryGreenDark
                      : DozColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${message.isAdmin ? 'Admin • ' : ''}${DozFormatters.timeAgo(message.sentAt, lang: 'en')}',
              style: const TextStyle(
                fontSize: 10,
                color: DozColors.textDisabledLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
