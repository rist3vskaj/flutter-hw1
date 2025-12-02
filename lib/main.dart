import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

void main() {
  runApp(const KototinderApp());
}

class KototinderApp extends StatelessWidget {
  const KototinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кототиндер',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const RootTabScaffold(),
    );
  }
}

class RootTabScaffold extends StatelessWidget {
  const RootTabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Кототиндер'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.favorite_border),
                text: 'Котики',
              ),
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Список пород',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            CatSwipeScreen(),
            BreedListScreen(),
          ],
        ),
      ),
    );
  }
}

class CatApiClient {
  CatApiClient(this._client);

  final http.Client _client;

  static const String _baseUrl = 'https://api.thecatapi.com/v1';

  Future<CatImage> fetchRandomCat() async {
    // First, get a random breed to ensure we have breed data
    final List<CatBreed> breeds = await fetchBreeds();
    if (breeds.isEmpty) {
      throw Exception('Не удалось загрузить список пород');
    }
    
    // Pick a random breed
    final CatBreed randomBreed = breeds[(DateTime.now().millisecondsSinceEpoch % breeds.length)];
    
    // Now fetch an image for this specific breed
    final uri = Uri.parse('$_baseUrl/images/search?breed_ids=${randomBreed.id}&limit=1');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки котика: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    if (decoded.isEmpty) {
      // If no image for this breed, try a random image with breed data
      return _fetchRandomCatWithBreed();
    }

    final Map<String, dynamic> imageData = decoded.first as Map<String, dynamic>;
    // Manually add breed data to the image response
    imageData['breeds'] = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': randomBreed.id,
        'name': randomBreed.name,
        'origin': randomBreed.origin,
        'description': randomBreed.description,
        'temperament': randomBreed.temperament,
        'life_span': randomBreed.lifeSpan,
        'intelligence': randomBreed.intelligence,
        'energy_level': randomBreed.energyLevel,
        'affection_level': randomBreed.affectionLevel,
      },
    ];

    return CatImage.fromJson(imageData);
  }
  
  Future<CatImage> _fetchRandomCatWithBreed() async {
    // Fallback: try to get a random image with breed data
    final uri = Uri.parse('$_baseUrl/images/search?has_breeds=1&size=med&limit=1');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки котика: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    if (decoded.isEmpty) {
      throw Exception('Сервер вернул пустой ответ для котика');
    }

    return CatImage.fromJson(decoded.first as Map<String, dynamic>);
  }

  Future<List<CatBreed>> fetchBreeds() async {
    final uri = Uri.parse('$_baseUrl/breeds');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки списка пород: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((dynamic json) => CatBreed.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Что-то пошло не так'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      );
    },
  );
}

class CatSwipeScreen extends StatefulWidget {
  const CatSwipeScreen({super.key});

  @override
  State<CatSwipeScreen> createState() => _CatSwipeScreenState();
}

class _CatSwipeScreenState extends State<CatSwipeScreen> {
  late final CatApiClient _apiClient;

  CatImage? _currentCat;
  bool _isLoading = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = CatApiClient(http.Client());
    _loadNextCat();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNextCat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final CatImage cat = await _apiClient.fetchRandomCat();
      setState(() {
        _currentCat = cat;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorDialog(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleDislike() {
    _loadNextCat();
  }

  void _handleLike() {
    setState(() {
      _likesCount++;
    });
    _loadNextCat();
  }

  void _handleTapOnCat() {
    final CatImage? cat = _currentCat;
    if (cat == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => CatDetailScreen(catImage: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CatImage? cat = _currentCat;
    final String breedName = cat?.breed?.name ?? 'Неизвестная порода';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Свайпни котика',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                avatar: const Icon(Icons.favorite, color: Colors.redAccent),
                label: Text('Лайков: $_likesCount'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _isLoading && cat == null
                  ? const CircularProgressIndicator()
                  : _buildCatCard(cat, breedName),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _isLoading ? null : _handleDislike,
                icon: const Icon(Icons.close),
                label: const Text('Дизлайк'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _isLoading ? null : _handleLike,
                icon: const Icon(Icons.favorite),
                label: const Text('Лайк'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatCard(CatImage? cat, String breedName) {
    if (cat == null) {
      return const Text('Не удалось загрузить котика :(');
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Dismissible(
          key: ValueKey<String>(cat.id),
          direction: DismissDirection.horizontal,
          onDismissed: (DismissDirection direction) {
            // Важно: сначала убрать виджет из дерева, затем обработать действие,
            // чтобы не получать красный экран про "Dismissible widget is still part of the tree".
            setState(() {
              _currentCat = null;
            });

            if (direction == DismissDirection.endToStart) {
              _handleDislike();
            } else {
              _handleLike();
            }
          },
          child: GestureDetector(
            onTap: _handleTapOnCat,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: cat.url,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (BuildContext context, String url, Object error) =>
                        const Icon(Icons.broken_image, size: 64),
                  ),
                  // Gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            breedName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          if (cat.breed?.origin != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              cat.breed!.origin,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                shadows: const <Shadow>[
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CatDetailScreen extends StatelessWidget {
  const CatDetailScreen({required this.catImage, super.key});

  final CatImage catImage;

  @override
  Widget build(BuildContext context) {
    final CatBreed? breed = catImage.breed;
    return Scaffold(
      appBar: AppBar(
        title: Text(breed?.name ?? 'Котик'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: CachedNetworkImage(
                  imageUrl: catImage.url,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (BuildContext context, String url, Object error) =>
                      const Icon(Icons.broken_image, size: 64),
                ),
            ),
            ),
            const SizedBox(height: 24),
            if (breed != null) ...<Widget>[
              // Breed name header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  breed.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Origin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Страна происхождения: ${breed.origin}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Description
              const Text(
                'Описание породы',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                breed.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Characteristics section
              const Text(
                'Характеристики',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <Widget>[
                    _buildCharacteristicRow('Характер', breed.temperament.isNotEmpty ? breed.temperament : 'Не указано'),
                    const Divider(height: 24),
                    _buildCharacteristicRow('Продолжительность жизни', breed.lifeSpan.isNotEmpty ? '${breed.lifeSpan} лет' : 'Не указано'),
                    const Divider(height: 24),
                    _buildCharacteristicRow('Интеллект', '${breed.intelligence}/5'),
                    const Divider(height: 24),
                    _buildCharacteristicRow('Энергичность', '${breed.energyLevel}/5'),
                    const Divider(height: 24),
                    _buildCharacteristicRow('Ласковость', '${breed.affectionLevel}/5'),
                  ],
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Подробная информация о породе недоступна',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Этот котик не имеет данных о породе в базе',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(value),
        ),
      ],
    );
  }
}

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  late final CatApiClient _apiClient;
  List<CatBreed> _breeds = <CatBreed>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiClient = CatApiClient(http.Client());
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<CatBreed> breeds = await _apiClient.fetchBreeds();
      setState(() {
        _breeds = breeds;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showErrorDialog(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _breeds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_breeds.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: _loadBreeds,
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить загрузку пород'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBreeds,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _breeds.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(height: 0),
        itemBuilder: (BuildContext context, int index) {
          final CatBreed breed = _breeds[index];
          final String shortDescription =
              breed.description.length > 90 ? '${breed.description.substring(0, 90)}…' : breed.description;

          return ListTile(
            title: Text(breed.name),
            subtitle: Text(
              '$shortDescription\nСтрана: ${breed.origin}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => BreedDetailScreen(breed: breed),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BreedDetailScreen extends StatelessWidget {
  const BreedDetailScreen({required this.breed, super.key});

  final CatBreed breed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              breed.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Происхождение: ${breed.origin}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              breed.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Основные характеристики',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildCharacteristicRow('Характер', breed.temperament),
            const SizedBox(height: 8),
            _buildCharacteristicRow('Продолжительность жизни', '${breed.lifeSpan} лет'),
            const SizedBox(height: 8),
            _buildCharacteristicRow('Интеллект', '${breed.intelligence}/5'),
            const SizedBox(height: 8),
            _buildCharacteristicRow('Энергичность', '${breed.energyLevel}/5'),
            const SizedBox(height: 8),
            _buildCharacteristicRow('Ласковость', '${breed.affectionLevel}/5'),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(value),
        ),
      ],
    );
  }
}


