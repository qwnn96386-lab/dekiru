import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("會員"),
        // 移除預設卡片，改為只有添加按鈕
        _buildAddButton(),
        const SizedBox(height: 20),
        
        _buildSectionHeader("行動支付"),
        // 移除預設卡片
        _buildAddButton(),
        const SizedBox(height: 20),
        
        _buildSectionHeader("載具"),
        // 移除預設卡片
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {
          // 這裡未來實作新增邏輯
        }),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {}, // 實作新增邏輯
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: const Center(child: Icon(Icons.add, color: Colors.grey)),
      ),
    );
  }
}