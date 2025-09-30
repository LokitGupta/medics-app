import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../models/article.dart';
import '../../core/constants.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildArticleContent(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _shareArticle(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(article.category),
              size: 80,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareArticle(context),
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: () => _toggleBookmark(context),
          icon: const Icon(Icons.bookmark_border),
        ),
      ],
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          if (article.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                article.category!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          if (article.category != null) const SizedBox(height: 20),

          // Title
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          // Author and Date Info
          _buildAuthorSection(),

          const SizedBox(height: 24),

          // Summary (if available)
          if (article.summary != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Article Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.summary!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Reading Time Estimate
          _buildReadingTimeWidget(),

          const SizedBox(height: 24),

          // Article Content
          SizedBox(
            width: double.infinity,
            child: Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.justify,
            ),
          ),

          const SizedBox(height: 32),

          // Tags Section (if we had tags)
          _buildTagsSection(),

          const SizedBox(height: 32),

          // Medical Disclaimer
          _buildDisclaimerSection(),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(context),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAuthorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Author Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.author ?? 'Medical Team',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Published ${_formatDate(article.publishedAt)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingTimeWidget() {
    final wordCount = article.content.split(' ').length;
    final readingTimeMinutes = (wordCount / 200)
        .ceil(); // Average reading speed

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 6),
          Text(
            '$readingTimeMinutes min read',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    // Generate some tags based on category and content
    final tags = _generateTags();

    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Topics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Medical Disclaimer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This article is for informational purposes only and should not be considered as medical advice. Always consult with a qualified healthcare professional before making any decisions about your health or treatment.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareArticle(context),
            icon: const Icon(Icons.share),
            label: const Text('Share Article'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleBookmark(context),
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Save Article'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _generateTags() {
    final tags = <String>[];

    // Add category as a tag
    if (article.category != null) {
      tags.add(article.category!);
    }

    // Generate tags based on content keywords (simple implementation)
    final content = article.content.toLowerCase();
    final commonMedicalTerms = [
      'health',
      'treatment',
      'prevention',
      'symptoms',
      'diagnosis',
      'exercise',
      'nutrition',
      'wellness',
      'care',
      'medicine',
    ];

    for (final term in commonMedicalTerms) {
      if (content.contains(term) && tags.length < 6) {
        tags.add(term.capitalize());
      }
    }

    return tags;
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'cardiology':
        return Icons.favorite;
      case 'dermatology':
        return Icons.face;
      case 'pediatrics':
        return Icons.child_care;
      case 'orthopedics':
        return Icons.accessibility;
      case 'neurology':
        return Icons.psychology;
      case 'mental health':
        return Icons.psychology_alt;
      case 'nutrition':
        return Icons.restaurant;
      case 'general health':
        return Icons.health_and_safety;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _shareArticle(BuildContext context) {
    final shareText =
        '''
📱 Check out this health article from Medics App:

${article.title}

${article.summary ?? article.content.substring(0, 150)}...

#HealthTips #MedicsApp #HealthCare
    ''';

    // Copy to clipboard (simple share implementation)
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Article link copied to clipboard!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBookmark(BuildContext context) {
    // This would typically save to local storage or user preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bookmark, color: Colors.white),
            SizedBox(width: 8),
            Text('Article saved to bookmarks!'),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to bookmarks screen
          },
        ),
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
