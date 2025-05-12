import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class LoginWidget extends BaseWidget {
  const LoginWidget(this.onLogin, {super.key});

  final void Function(bool) onLogin;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LoginWidgetState();
  }
}

class LoginWidgetState extends BaseWidgetState<LoginWidget, LoginWidgetModel> {
  final provider = ChangeNotifierProvider((ref) => LoginWidgetModel());
  
  @override
  Widget getWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48),
      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/ui/banners/carved_slide.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          TextField(
            controller: model.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: model.passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          GameButton(
            onPressed: () {
              model.login(widget.onLogin);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  LoginWidgetModel getWidgetModel() {
    return ref.read(provider);
  }

}

class LoginWidgetModel extends BaseWidgetModel {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login(void Function(bool) onDone) async {
    try {
      await userRepo.signInWithEmail(emailController.text, passwordController.text);
      if (userRepo.user != null) {
        onDone(true);
      } else {
        onDone(false);
      }
    } catch (err, stack) {
      onDone(false);
      AppException.log(runtimeType, err, stack);
    }
  } 
}