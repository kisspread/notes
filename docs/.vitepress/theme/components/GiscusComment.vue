<template>
    <div style="margin-top: 24px">
        <Giscus
            id="comments"
            repo="kisspread/notes"
            repoid="R_kgDOMNKAqg"
            category="Announcements"
            categoryid="DIC_kwDOMNKAqs4CgVZ_"
            mapping="pathname"
            term="Welcome to giscus!"
            reactionsenabled="1"
            emitmetadata="1"
            inputposition="top"
            loading="lazy"
            :theme="isDark ? 'dark' : 'light'"
            :key="route.path"
        ></Giscus>
    </div>
</template>

<script setup>
import Giscus from '@giscus/vue';
import { useRoute, useData } from 'vitepress';

const route = useRoute();
const { isDark } = useData();
</script>