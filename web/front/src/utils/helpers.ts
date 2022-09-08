// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const setAll = (state: any, properties: any) => {
    const props = Object.keys(properties)
    props.forEach(key => {
        state[key] = properties[key]
    })
}
