import 'package:chat_app/core/navigation/routes/routes_name.dart';
import 'package:chat_app/core/utils/user_data.dart';
import 'package:chat_app/core/widgets/text_field.dart';
import 'package:chat_app/feature/signup/presentation/riverpod/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../../core/utils/google_sign_in.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isButtonEnable = false;

  ({
    bool email,
    bool password,
    bool confirmPassword,
    bool name
  }) enableButtonNotifier =
      (email: false, password: false, confirmPassword: false, name: false);

  @override
  void initState() {
    super.initState();

    _userName.addListener(
      () => updateEnableButtonNotifier(),
    );

    _emailController.addListener(
      () => updateEnableButtonNotifier(),
    );

    _passwordController.addListener(
      () => updateEnableButtonNotifier(),
    );

    _confirmPasswordController.addListener(
      () => updateEnableButtonNotifier(),
    );
  }

  void updateEnableButtonNotifier() {
    setState(() {
      enableButtonNotifier = (
        name: _userName.value.text.isNotEmpty,
        email: _emailController.value.text.isNotEmpty,
        password: _passwordController.value.text.isNotEmpty,
        confirmPassword: _confirmPasswordController.value.text.isNotEmpty
      );

      isButtonEnable = enableButtonNotifier.email &&
          enableButtonNotifier.password &&
          enableButtonNotifier.confirmPassword &&
          enableButtonNotifier.name;
    });
  }

  Widget build(BuildContext context) {
    final state = ref.watch(signUpControllerProvider);

    ref.listen(signUpControllerProvider, (_, next) {
      if (next.value?.$1 == null && next.value?.$2 == null) {
        const CircularProgressIndicator();
      } else if (next.value?.$1 != null && next.value?.$2 == null) {
        context.go(RoutesName.login);
      } else if (next.value?.$1 == null && next.value?.$2 != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error!'),
              content: Text('${next.value?.$2}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.message,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  "Let's create an account for you",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  hintText: 'User Name',
                  obscureText: false,
                  controller: _userName,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'User name is required';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  hintText: 'Email',
                  obscureText: false,
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  hintText: 'Password',
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  hintText: 'Confirm Password',
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value!.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      if (value != _passwordController.text) {
                        return "Password and confirm password doesn't match";
                      }
                    }
                    if (value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: ElevatedButton(
                    onPressed: (isButtonEnable)
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(signUpControllerProvider.notifier).signUp(
                                    UserData(
                                      name: _userName.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(
                            backgroundColor: Colors.white10,
                          )
                        : Text(
                            'SignUp',
                            style: !isButtonEnable
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.titleSmall,
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go(RoutesName.login);
                      },
                      child: Text(
                        "LogIn",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      ' OR ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 40,
                  width: 190,
                  child: SignInButton(
                    Buttons.google,
                    onPressed: () async {
                      final userCredential =
                          await MyGoogleSignIn().signInWithGoogle();
                      if (userCredential != null) {
                        final user = userCredential.user;
                        ref
                            .read(signUpControllerProvider.notifier)
                            .saveGoogleUser(user: user);
                        print(user!.photoURL);
                        context.go(RoutesName.home);
                      } else {
                        print("SignIn failed!");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
