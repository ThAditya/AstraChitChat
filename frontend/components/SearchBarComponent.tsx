import * as api from '@/services/api';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import React, { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Image,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  Platform,
  Keyboard,
} from 'react-native';
import { useTheme } from '@/hooks/use-theme-color';

interface SearchResult {
  _id: string;
  username?: string;
  name?: string;
  profilePicture?: string;
  type: 'user' | 'chat' | 'query';
}

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    zIndex: 100,
    elevation: Platform.OS === 'android' ? 5 : 0,
  },
  searchContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingVertical: 10,
    alignItems: 'center',
  },
  searchWrapper: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 22,
    height: 44,
    paddingHorizontal: 12,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    height: '100%',
    fontSize: 16,
    paddingVertical: 0,
    textAlignVertical: 'center',
  },
  suggestionsContainer: {
    position: 'absolute',
    top: 64,
    left: 16,
    right: 16,
    borderRadius: 12,
    maxHeight: 400,
    zIndex: 1000,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    overflow: Platform.OS === 'android' ? 'hidden' : 'visible',
  },
  suggestionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 14,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  suggestionText: { fontSize: 16, marginLeft: 10 },
  profilePic: {
    width: 32,
    height: 32,
    borderRadius: 16,
  },
  loadingContainer: {
    position: 'absolute',
    top: 64,
    left: 16,
    right: 16,
    borderRadius: 12,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    zIndex: 100,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  loadingText: { fontSize: 16, marginLeft: 10 },
  errorContainer: {
    position: 'absolute',
    top: 64,
    left: 16,
    right: 16,
    borderRadius: 12,
    padding: 16,
    zIndex: 100,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  errorText: { fontSize: 16, textAlign: 'center' },
});

export default function SearchBarComponent() {
  const router = useRouter();
  const colors = useTheme();
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const debounceTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);

  const handleSearch = async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      setShowSuggestions(false);
      setLoading(false);
      setError(null);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const data = await api.get(`/search?q=${encodeURIComponent(query)}`);

      // Handle both formats: { users: [...] } or direct array
      const usersArray = Array.isArray(data) ? data : data.users || [];
      const users = usersArray.map((user: any) => ({ ...user, type: 'user' }));

      // Add typed query as first suggestion
      setSearchResults([{ _id: 'query', username: query, type: 'query' }, ...users]);
      setShowSuggestions(true);
    } catch (err: any) {
      console.error('Search error:', err);
      setError(err.response?.data?.message || err.message || 'Search failed');
      setSearchResults([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (debounceTimeout.current) clearTimeout(debounceTimeout.current);

    if (searchQuery.trim().length > 0) {
      setError(null);
      debounceTimeout.current = setTimeout(() => handleSearch(searchQuery), 300);
    } else {
      setShowSuggestions(false);
      setSearchResults([]);
      setError(null);
    }

    return () => {
      if (debounceTimeout.current) clearTimeout(debounceTimeout.current);
    };
  }, [searchQuery]);

  const handleResultPress = (item: SearchResult) => {
    Keyboard.dismiss();
    if (item.type === 'query') {
      handleSearch(item.username || '');
      return;
    }

    if (item.type === 'user') {
      // Navigate to home tab with profile modal
      router.push(`/profile/${item._id}`);
    } else {
      router.push({ pathname: '/chat/detail', params: { chatId: item._id } });
    }

    setSearchQuery('');
    setSearchResults([]);
    setShowSuggestions(false);
  };

  const handleMessage = async (userId: string) => {
    try {
      const data = await api.post('/chats', { participants: [userId] });
      router.push(`/chat?chatId=${data._id}`);
      setSearchQuery('');
      setSearchResults([]);
      setShowSuggestions(false);
    } catch (error: any) {
      Alert.alert('Error', error.response?.data?.message || 'Failed to start chat');
    }
  };

  const renderSuggestion = ({ item }: { item: SearchResult }) => (
    <TouchableOpacity 
      style={[styles.suggestionItem, { borderBottomColor: colors.border }]} 
      onPress={() => handleResultPress(item)}
      activeOpacity={0.7}
    >
      {item.type === 'query' ? (
        <Ionicons name="search-outline" size={20} color={colors.textMuted} />
      ) : item.profilePicture ? (
        <Image source={{ uri: item.profilePicture }} style={[styles.profilePic, { backgroundColor: colors.backgroundTertiary }]} />
      ) : (
        <Ionicons name="person-circle-outline" size={24} color={colors.tint} />
      )}
      <Text style={[styles.suggestionText, { color: colors.text }]} numberOfLines={1}>
        {item.type === 'query' ? `Search for "${item.username}"` : item.username}
      </Text>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={[styles.searchContainer, { backgroundColor: colors.background }]}>
        <View style={[styles.searchWrapper, { backgroundColor: colors.backgroundSecondary }]}>
          <Ionicons name="search-outline" size={20} color={colors.textMuted} style={styles.searchIcon} />
          <TextInput
            style={[styles.searchInput, { color: colors.text }]}
            placeholder="Search users and chats..."
            placeholderTextColor={colors.textMuted}
            value={searchQuery}
            onChangeText={setSearchQuery}
            onSubmitEditing={() => handleSearch(searchQuery)}
            returnKeyType="search"
            autoCorrect={false}
            autoCapitalize="none"
            underlineColorAndroid="transparent"
          />
        </View>
      </View>

      {loading && (
        <View style={[styles.loadingContainer, { backgroundColor: colors.backgroundSecondary }]}>
          <ActivityIndicator size="small" color={colors.tint} />
          <Text style={[styles.loadingText, { color: colors.text }]}>Searching...</Text>
        </View>
      )}

      {error && !loading && (
        <View style={[styles.errorContainer, { backgroundColor: colors.error }]}>
          <Text style={[styles.errorText, { color: colors.background }]}>{error}</Text>
        </View>
      )}

      {showSuggestions && !loading && !error && searchResults.length > 0 && (
        <View style={[styles.suggestionsContainer, { backgroundColor: colors.backgroundSecondary }]}>
          <FlatList
            data={searchResults}
            keyExtractor={item => item._id || item.username || Math.random().toString()}
            renderItem={renderSuggestion}
            keyboardShouldPersistTaps="handled"
          />
        </View>
      )}
    </View>
  );
}
