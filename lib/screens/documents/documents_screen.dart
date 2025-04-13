import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_text_field.dart';
import 'add_document_screen.dart';
import 'widgets/document_card.dart';

class DocumentsScreen extends StatefulWidget {
  static const String routeName = '/documents';
  
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDocuments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
        _isSearching = false;
      });
      
      await documentProvider.loadDocuments(authProvider.currentUser!.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _searchDocuments(String query) async {
    if (query.trim().isEmpty) {
      return _loadDocuments();
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
        _isSearching = true;
      });
      
      await documentProvider.searchDocuments(
        authProvider.currentUser!.id, 
        query.trim(),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _addDocument() {
    Navigator.pushNamed(context, AddDocumentScreen.routeName).then((_) {
      _loadDocuments();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tài Liệu',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Tìm kiếm tài liệu...',
              prefixIcon: Icons.search,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadDocuments();
                      },
                    )
                  : null,
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadDocuments();
                }
              },
              onSubmitted: (value) {
                _searchDocuments(value);
              },
            ),
          ),
          
          // Kết quả tìm kiếm hoặc danh sách tài liệu
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Đang tải tài liệu...')
                : _isSearching && documentProvider.documents.isEmpty
                    ? EmptyState(
                        title: 'Không tìm thấy kết quả',
                        message: 'Không tìm thấy tài liệu phù hợp với từ khóa "${_searchController.text}"',
                        icon: Icons.search_off,
                        actionLabel: 'Xem tất cả',
                        onActionPressed: _loadDocuments,
                      )
                    : documentProvider.documents.isEmpty
                        ? const EmptyState(
                            title: 'Chưa có tài liệu nào',
                            message: 'Thêm tài liệu để quản lý và truy cập nhanh chóng',
                            icon: Icons.folder_open,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: documentProvider.documents.length,
                              itemBuilder: (context, index) {
                                final document = documentProvider.documents[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: DocumentCard(
                                    document: document,
                                    onRefresh: _loadDocuments,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDocument,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        tooltip: 'Thêm tài liệu',
      ),
    );
  }
}