<template>
  <div>
    <div class="container mx-auto py-14 space-y-14">
      <div class="flex justify-center -mx-6">
        <div class="self-center px-4 py-4 mx-6">
          <img src="/logo.svg" class="block h-auto mx-auto w-28">
          <h1 class="mt-5 text-3xl font-semibold tracking-wider text-center uppercase">Should I automate It?</h1>
        </div>
        <div class="mx-6">
          <h3 class="mb-2 text-lg font-medium leading-6 tracking-wider text-center">Task</h3>
          <div class="max-w-xs px-4 py-4 space-y-4 bg-white border border-gray-400 rounded-sm shadow-sm">
            <v-input
              title="Duration"
              hint="in Minutes"
              type="integer"
              post="min"
              min="1"
              v-model="taskDuration"
              required
            />
            <v-input
              title="Recurrence"
              hint="per Week"
              type="number"
              post="x"
              min="0.1"
              v-model="taskRecurrence"
              required
            />
            <v-input
              title="Costs"
              hint="per Hour"
              post="€/h"
              type="number"
              min="1"
              v-model="taskHourlyCosts"
              required
            />
          </div>
        </div>
        <div class="mx-6">
          <h3 class="mb-2 text-lg font-medium leading-6 tracking-wider text-center">Automation</h3>
          <div class="max-w-xs px-4 py-4 space-y-4 bg-white border border-gray-400 rounded-sm shadow-sm">
            <v-input
              title="Duration"
              hint="in Hours"
              type="integer"
              post="hours"
              min="1"
              v-model="autoDuration"
              required
            />
            <v-input
              title="Costs"
              hint="per Hour"
              post="€/h"
              type="number"
              min="1"
              v-model="autoHourlyCosts"
              required
            />
          </div>
        </div>
      </div>

      <div>
        <h3 class="px-4 mb-2 text-lg font-medium leading-6 tracking-wider text-center">Amortization in Weeks</h3>
        <div>
          <table class="w-full leading-none table-fixed tabular-nums whitespace-nowrap">
            <tbody>
              <tr>
                <td class="w-16 px-2 py-2"></td>
                <td class="w-24 px-2 py-2 border-r border-gray-400"></td>
                <td :colspan="autoDurationSpread.length" class="px-2 py-2 font-medium text-center">Automation Duration</td>
              </tr>
              <tr class="font-medium border-b border-gray-400">
                <td class="px-2 py-2"></td>
                <td class="px-2 py-2 border-r border-gray-400"></td>
                <td
                  v-for="dur of autoDurationSpread"
                  :key="dur"
                  class="px-2 py-2 text-center"
                  :class="{ 'bg-amber-500 bg-opacity-20 font-semibold': dur === autoDuration }"
                  v-text="dur"
                />
              </tr>
              <tr
                v-for="(rec, i) of taskRecurrenceSpread"
                :key="rec"
                :class="{ 'bg-amber-500 bg-opacity-20': rec === taskRecurrence }"
              >
                <td
                  v-if="i === 0"
                  class="relative w-16 px-0 py-0"
                  :rowspan="taskRecurrenceSpread.length"
                >
                  <div class="relative w-full h-full bg-red-500">
                    <div class="absolute z-10 flex flex-col items-center justify-center w-16 h-full">
                      <div class="absolute font-medium text-center transform -rotate-90">Recurrences<br>per Week</div>
                    </div>
                  </div>
                </td>
                <td
                  class="px-2 py-2 font-medium text-right border-r border-gray-400"
                  :class="{ 'font-semibold': rec === taskRecurrence }"
                  v-text="rec"
                />
                <td
                  v-for="dur of autoDurationSpread"
                  :key="dur"
                  class="px-2 py-2 text-center"
                  :class="{
                    'bg-amber-500 bg-opacity-20': dur === autoDuration,
                    'font-semibold': dur === autoDuration && rec === taskRecurrence
                  }"
                  v-html="getAmortization(rec, dur)"
                />
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import vInput from './components/v-input.vue'
  import { formatNum } from '@krknet/fe/helpers'

  import { scaleLinear } from 'd3-scale'

  export default {
    components: { vInput },
    data () {
      return  {
        taskDuration: 5, // Duration in Minutes
        taskRecurrence: 5, // Recurrences per KW
        taskHourlyCosts: 20,
        autoDuration: 5, // Duration in Hours
        autoHourlyCosts: 100
      }
    },
    computed: {
      taskRecurrenceSpread () {
        return scaleLinear().domain([this.taskRecurrence * 0.5, this.taskRecurrence * 1.5]).nice().ticks(5)
      },
      autoDurationSpread () {
        return scaleLinear().domain([this.autoDuration * 0.5, this.autoDuration * 1.5]).nice().ticks(5)
      },
      taskCostPerMinute () {
        return this.taskHourlyCosts / 60
      }
    },
    methods: {
      getAmortization (recurrence, duration) {
        const task = this.taskDuration * this.taskCostPerMinute * recurrence
        const auto = duration * this.autoHourlyCosts
        return formatNum(Math.ceil(auto / task))
      }
    }
  }
</script>
