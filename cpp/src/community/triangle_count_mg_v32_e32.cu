/*
 * Copyright (c) 2022-2024, NVIDIA CORPORATION.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "community/triangle_count_impl.cuh"

namespace cugraph {

template void triangle_count(raft::handle_t const& handle,
                             graph_view_t<int32_t, int32_t, false, true> const& graph_view,
                             std::optional<raft::device_span<int32_t const>> vertices,
                             raft::device_span<int32_t> counts,
                             bool do_expensive_check);

}  // namespace cugraph
