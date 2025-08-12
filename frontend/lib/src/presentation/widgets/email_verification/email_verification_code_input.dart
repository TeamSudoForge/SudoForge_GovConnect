import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_export.dart';
import '../custom_button.dart';

class EmailVerificationCodeInput extends StatelessWidget {
  final List<TextEditingController> codeControllers;
  final List<FocusNode> codeFocusNodes;
  final void Function(String, int) onCodeInput;
  final VoidCallback onVerificationSubmit;

  const EmailVerificationCodeInput({
    required this.codeControllers,
    required this.codeFocusNodes,
    required this.onCodeInput,
    required this.onVerificationSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter verification code',
            style: TextStyleHelper.instance.body14
                .copyWith(color: appTheme.colorFF4040, height: 1.21),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Container(
                width: 48,
                height: 48,
                child: TextFormField(
                  controller: codeControllers[index],
                  focusNode: codeFocusNodes[index],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyleHelper.instance.title18Medium,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: appTheme.whiteCustom,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: appTheme.colorFFD4D4, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: appTheme.colorFFD4D4, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: appTheme.colorFF007B, width: 2),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    onCodeInput(value, index);
                  },
                  onTap: () {
                    codeControllers[index].selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: codeControllers[index].text.length),
                    );
                  },
                  onFieldSubmitted: (value) {
                    if (index < 5) {
                      codeFocusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 24),
          CustomButton(
            text: 'Verify Email',
            onPressed: onVerificationSubmit,
            isFullWidth: true,
            height: 48,
            backgroundColor: appTheme.colorFF007B,
            textColor: appTheme.whiteCustom,
            fontSize: 16,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}
