import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../bloc/admin_user_bloc.dart';
import '../../models/user.dart';
import '../../widgets/admin/user_form_widget.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminUserBloc>().add(const FetchAdminUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminUserBloc, AdminUserState>(
      listener: (context, state) {
        if (state is AdminUserSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AdminUserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AdminUserBloc, AdminUserState>(
        builder: (context, state) {
          if (state is AdminUserLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentGreen,
              ),
            );
          } else if (state is AdminUserLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Admin Users',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showUserDialog(context, null),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.users.isEmpty)
                    Center(
                      child: Text(
                        'No users',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...state.users.map((user) =>
                        _buildUserCard(user, context)),
                ],
              ),
            );
          } else if (state is AdminUserError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserCard(User user, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _showUserDialog(context, user),
                  icon: const Icon(Icons.edit),
                  color: AppTheme.accentGreen,
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    context
                        .read<AdminUserBloc>()
                        .add(DeleteAdminUser(user.uid));
                  },
                  icon: const Icon(Icons.delete),
                  color: Color(0xFFEF5350),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBg,
        child: UserFormWidget(
          user: user,
          onSubmit: (email, displayName, password, role) {
            if (user == null) {
              context.read<AdminUserBloc>().add(
                    AddAdminUser(
                      email: email,
                      displayName: displayName,
                      password: password,
                      role: role,
                    ),
                  );
            } else {
              context.read<AdminUserBloc>().add(
                    UpdateAdminUserRole(
                      userId: user.uid,
                      newRole: role,
                    ),
                  );
            }
          },
        ),
      ),
    );
  }
}
