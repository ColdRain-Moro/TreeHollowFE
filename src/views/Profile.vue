<script setup lang="ts">
import {background, unimportant} from '../themes/color.js'
import {fetchX} from "../service/frontend";
import {backendApiUrl} from "../configurations/config";
import {useRouter} from "vue-router";
import {computed, onMounted, reactive, ref, watch, watchEffect} from "vue";
import {useUserInfoStore} from "../stores/userInfo";
import PreviewCard from "../components/home/PreviewCard.vue";

const router = useRouter()
const userInfoStore = useUserInfoStore()

const info = computed(() => userInfoStore.info)
const isAdmin = computed(() => userInfoStore.isAdmin)
const currentPage = ref(0);
const pagerData = [
  {
    index: 0,
    tab: "收藏",
    page: 0,
    loaded: reactive([]),
  },
  {
    index: 1,
    tab: "帖子",
    page: 0,
    loaded: reactive([]),
  }
];

async function loadMore({ done }) {
  const pageData = pagerData[currentPage.value]
  const requestUrl = backendApiUrl + (pageData.index == 0 ? "/post/star/list" : "/post/userPosts") + "?page=" + pageData.page;
  const data: any[] = await fetchX(requestUrl).then(r => r.json());
  if (data.length == 0) {
    done('empty')
    return
  }
  console.log(data)
  pageData.loaded = [...pageData.loaded, ...data]
  console.log(pageData.loaded)
  pageData.page++
  done('ok')
}

function handleClickLogout() {
  fetchX(backendApiUrl + "/auth/logout", {
    method: "GET"
  }).then((res) => {
    if (res.status === 200) {
      router.push("/?snakebar=退出登录成功")
    }
  })
  userInfoStore.logout()
}

const emit = defineEmits(['modifytitle', 'modifyicon', 'modifyactions'])

function handleClickAppbarIcon() {
  router.back()
}

onMounted(() => {
  emit('modifytitle', "我的档案")
  emit('modifyicon', {
    icon: "mdi-arrow-left",
    tooltip: "返回上一页",
    handler: handleClickAppbarIcon
  })
  emit('modifyactions', undefined)
})

</script>

<template>
  <template v-if="isAdmin">{{ info }}</template>
  <br/>
  <v-btn @click="handleClickLogout">退出登录</v-btn>
  <br />
  <br />
  <v-tabs
    v-model="currentPage"
    align-tabs="center"
    fixed-tabs
  >
    <v-tab
      v-for="item in pagerData"
      :key="item.index"
      :value="item.index"
    >
      {{ item.tab }}
    </v-tab>
  </v-tabs>
  <v-divider />
  <v-window v-model="currentPage">
    <KeepAlive>
      <v-window-item
        v-for="n in pagerData"
        :key="n.index"
        :value="n.index"
      >
        <v-container fluid>
          <v-infinite-scroll :onLoad="loadMore">
            <template v-for="data in pagerData[currentPage].loaded">
              <div>
                <preview-card :data="data" :id="'post_'+data.id"></preview-card>
                <v-spacer class="mb-3"></v-spacer>
              </div>
            </template>
            <template v-slot:empty>
              <div class="no-more-post" id="no-more-post">
                <span class="no-more-post-content">已经到底了噢</span>
                <v-divider class="mx-16 my-4" style="size: 16px"></v-divider>
              </div>
            </template>
          </v-infinite-scroll>
        </v-container>
      </v-window-item>
    </KeepAlive>  
  </v-window>
</template>

<style scoped>
.no-more-post {
  margin: 0 auto;
  text-align: center;
  padding-top: 20px;
  padding-bottom: 20px;
}

.no-more-post-content {
  position: absolute;
  left: 50%;
  transform: translate(-50%, 25%);
  font-size: 14px;
  color: v-bind(unimportant);
  background-color: v-bind(background);
  z-index: 100;
}
</style>
