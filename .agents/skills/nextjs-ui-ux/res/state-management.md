# State Management

Use **TanStack Query** for all server-side state management and data fetching.

## 1. Query Client Setup

Ensure the `QueryClientProvider` is properly wrapping the application in Next.js (usually inside a Client Component wrapper in `app/layout.tsx`).

## 2. Fetching Data (Queries)

Create custom hooks for data fetching to encapsulate the query keys and fetching logic.

```tsx
import { useQuery } from '@tanstack/react-query';
import { getCharacter } from '@/lib/api/characters';

export function useCharacter(id: string) {
  return useQuery({
    queryKey: ['character', id],
    queryFn: () => getCharacter(id),
    staleTime: 1000 * 60 * 5, // 5 minutes
  });
}
```

## 3. Modifying Data (Mutations)

Use `useMutation` for POST/PUT/DELETE requests, and handle query invalidation to automatically refetch fresh data.

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createCharacter } from '@/lib/api/characters';

export function useCreateCharacter() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createCharacter,
    onSuccess: () => {
      // Invalidate and refetch character list
      queryClient.invalidateQueries({ queryKey: ['characters'] });
    },
  });
}
```
