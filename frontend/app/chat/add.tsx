import TopHeaderComponent from '@/components/TopHeaderComponent';
import React, { useState, useEffect, useRef } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, TextInput, Alert, Image, Platform, ActivityIndicator, Keyboard } from 'react-native';
import { useRouter } from 'expo-router';
import { ThemedView } from '@/components/themed-view';
import { ThemedText } from '@/components/themed-text';
import { get, post } from '@/services/api';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useTheme } from '@/hooks/use-theme-color';
import { Ionicons } from '@expo/vector-icons';

interface User {
  _id: string;
  username: string;
  name: string;
  profilePicture: string;
}

export default function AddChatScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const colors = useTheme();
  const debounceTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (debounceTimeout.current) clearTimeout(debounceTimeout.current);

    if (searchQuery.trim().length > 0) {
      debounceTimeout.current = setTimeout(() => {
        searchUsers();
      }, 500);
    } else {
      setSearchResults([]);
    }

    return () => {
      if (debounceTimeout.current) clearTimeout(debounceTimeout.current);
    };
  }, [searchQuery]);

  const searchUsers = async () => {
    try {
      setLoading(true);
      const data = await get(`/users/search?q=${encodeURIComponent(searchQuery)}`);
      setSearchResults(data.users || []);
    } catch (error: any) {
      console.error('Search error:', error);
    } finally {
      setLoading(false);
    }
  };

  const startChat = async (user: User) => {
    Keyboard.dismiss();
    try {
      // Use the dedicated /create endpoint with userId field
      const chat = await post('/chats/create', { userId: user._id });
      router.push({
        pathname: '/chat/detail',
        params: {
          chatId: chat._id,
          otherUserId: user._id,
          otherUsername: user.username
        }
      });
    } catch (error: any) {
      Alert.alert('Error', error.response?.data?.message || 'Failed to start chat');
    }
  };

  const renderUser = ({ item }: { item: User }) => (
    <TouchableOpacity style={[styles.userItem, { backgroundColor: colors.card, borderColor: colors.border }]} onPress={() => startChat(item)}>
      <Image 
        source={{ uri: item.profilePicture || 'https://i.pravatar.cc/150' }} 
        style={styles.avatar} 
      />
      <View style={styles.userInfo}>
        <ThemedText type="subtitle">{item.username}</ThemedText>
        <Text style={{ color: colors.textTertiary, marginTop: 4 }}>{item.name}</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <ThemedView style={styles.container}>
      {/* Top Header now handles back navigation */}
      <TopHeaderComponent />

      <View style={[styles.searchContainer, { backgroundColor: colors.background }]}>
        <View style={[styles.searchWrapper, { backgroundColor: colors.input, borderColor: colors.border }]}>
          <Ionicons name="search" size={20} color={colors.placeholder} style={styles.searchIcon} />
          <TextInput
            style={[styles.searchInput, { color: colors.text }]}
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholder="Search users by username..."
            placeholderTextColor={colors.placeholder}
            autoCapitalize="none"
            autoCorrect={false}
            returnKeyType="search"
            underlineColorAndroid="transparent"
          />
          {loading && <ActivityIndicator size="small" color={colors.tint} style={styles.loader} />}
        </View>
      </View>

      {searchResults.length > 0 ? (
        <FlatList
          data={searchResults}
          renderItem={renderUser}
          keyExtractor={(item) => item._id}
          style={styles.resultsList}
          contentContainerStyle={styles.resultsContainer}
          keyboardShouldPersistTaps="handled"
        />
      ) : searchQuery.trim().length > 0 && !loading ? (
        <View style={styles.emptyContainer}>
          <Text style={[styles.emptyText, { color: colors.textSecondary }]}>No users found</Text>
        </View>
      ) : !loading ? (
        <View style={styles.emptyContainer}>
          <Text style={[styles.emptyText, { color: colors.textSecondary }]}>Search for users to start a chat</Text>
        </View>
      ) : null}
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  searchContainer: {
    padding: 16,
    zIndex: 1,
  },
  searchWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderRadius: 25,
    paddingHorizontal: 15,
    height: 50,
  },
  searchIcon: {
    marginRight: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    height: '100%',
    paddingVertical: 0,
  },
  loader: {
    marginLeft: 10,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontSize: 16,
  },
  resultsList: {
    flex: 1,
  },
  resultsContainer: {
    padding: 16,
  },
  userItem: {
    padding: 16,
    borderRadius: 8,
    marginBottom: 8,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    marginRight: 12,
  },
  userInfo: {
    flex: 1,
  },
  userName: {
    marginTop: 4,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 16,
    textAlign: 'center',
  },
});
